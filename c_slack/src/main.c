#include <cjson/cJSON.h>
#include <curl/curl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct Memory {
  char *response;
  size_t size;
};

size_t WriteCallback(void *data, size_t size, size_t nmemb, void *userp) {
  size_t totalSize = size * nmemb;
  struct Memory *mem = (struct Memory *)userp;

  // Reallocate memory for the response buffer
  char *ptr = realloc(mem->response, mem->size + totalSize + 1);
  if (ptr == NULL) {
    printf("Error: Not enough memory\n");
    return 0;
  }

  mem->response = ptr;
  memcpy(&(mem->response[mem->size]), data, totalSize);
  mem->size += totalSize;
  mem->response[mem->size] = '\0';

  return totalSize;
}

char *get_slack_auth_header() {
  const char *token = getenv("SLACK_TOKEN");
  if (token == NULL) {
    fprintf(stderr, "Error: SLACK_TOKEN environment variable not set\n");
    return NULL;
  }

  // Allocate memory for the header string
  char *auth_header = malloc(1024);
  if (auth_header == NULL) {
    fprintf(stderr, "Error: Memory allocation failed\n");
    return NULL;
  }

  snprintf(auth_header, 1024, "Authorization: Bearer %s", token);
  return auth_header;
}

int main(void) {
  CURL *curl;
  CURLcode res;

  curl_global_init(CURL_GLOBAL_DEFAULT);

  curl = curl_easy_init();
  if (curl) {
    struct Memory memory = {.response = NULL, .size = 0};

    curl_easy_setopt(curl, CURLOPT_URL,
                     "https://slack.com/api/conversations.list");

    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);

    // Pass the memory struct to the callback function
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *)&memory);

    struct curl_slist *chunk = NULL;

    /* Remove a header curl would otherwise add by itself */
    char *auth_header = get_slack_auth_header();
    if (auth_header == NULL) {
      curl_easy_cleanup(curl);
      curl_global_cleanup();
      return 1;
    }

    chunk = curl_slist_append(chunk, auth_header);
    free(auth_header);

    /* set our custom set of headers */
    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, chunk);

    /* cache the CA cert bundle in memory for a week */
    curl_easy_setopt(curl, CURLOPT_CA_CACHE_TIMEOUT, 604800L);

    /* Perform the request, res gets the return code */
    res = curl_easy_perform(curl);
    /* Check for errors */
    if (res != CURLE_OK)
      fprintf(stderr, "curl_easy_perform() failed: %s\n",
              curl_easy_strerror(res));

    cJSON *json = cJSON_Parse(memory.response);
    if (json == NULL) {
      const char *error_ptr = cJSON_GetErrorPtr();
      if (error_ptr != NULL) {
        fprintf(stderr, "Error before: %s\n", error_ptr);
      }
    } else {
      const cJSON *channels =
          cJSON_GetObjectItemCaseSensitive(json, "channels");
      if (cJSON_IsArray(channels)) {
        const cJSON *channel;
        cJSON_ArrayForEach(channel, channels) {
          cJSON *name = cJSON_GetObjectItemCaseSensitive(channel, "name");
          cJSON *num_members =
              cJSON_GetObjectItemCaseSensitive(channel, "num_members");
          printf("- %s [%d]\n", name->valuestring, num_members->valueint);
        }
      } else {
        printf("Something's wrong with the payload.");
      }
    }

    /* always cleanup */
    curl_easy_cleanup(curl);
    free(memory.response);
  }

  curl_global_cleanup();

  return 0;
}
