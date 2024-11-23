import type { SlackAPIChannelsResponse, SlackAPIUserResponse } from './schemas'

type SlackAPIResponse = SlackAPIChannelsResponse | SlackAPIUserResponse

interface SlackClientConfig {
  token: string
  baseUrl?: string
}

export class SlackClient {
  private token: string
  private baseUrl: string

  constructor(config: SlackClientConfig) {
    if (!config.token) {
      throw new Error('Slack token is required')
    }
    this.token = config.token
    this.baseUrl = config.baseUrl || 'https://slack.com/api'
  }

  private async request<T extends SlackAPIResponse>(
    endpoint: string,
    method = 'GET',
    qs?: Record<string, string>,
  ): Promise<T> {
    let url = `${this.baseUrl}/${endpoint}`
    const headers = {
      Authorization: `Bearer ${this.token}`,
      'Content-Type': 'application/json; charset=utf-8',
    }

    if (qs && Object.keys(qs).length > 0) {
      const searchParams = new URLSearchParams(qs)
      url = `${url}?${searchParams.toString()}`
    }

    try {
      const response = await fetch(url, {
        method,
        headers,
      })

      const result = await response.json()

      if (!result.ok) {
        throw new Error(result.error || 'Unknown Slack API error')
      }

      return result
    } catch (error) {
      throw new Error(`Slack API request failed: ${(error as Error).message}`)
    }
  }

  // Example methods for different Slack API endpoints
  async listChannels(): Promise<SlackAPIChannelsResponse> {
    return this.request('conversations.list')
  }

  async getUserInfo(userId: string): Promise<SlackAPIUserResponse> {
    return this.request('users.info', 'GET', { user: userId })
  }
}
