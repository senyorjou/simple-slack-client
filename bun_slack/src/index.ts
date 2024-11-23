import type { SlackAPIChannelsResponse, SlackChannel } from './schemas'
import { SlackClient } from './slack-client'
// Load environment variables from .env file

async function main() {
  const token = process.env.SLACK_TOKEN

  if (!token) {
    throw new Error('SLACK_TOKEN environment variable is required')
  }
  const slack = new SlackClient({ token })

  try {
    // Example: List channels
    const response: SlackAPIChannelsResponse = await slack.listChannels()
    const channelInfo = response.channels.map((channel: SlackChannel) => ({
      name: channel.name,
      numUsers: channel.num_members,
    }))
    console.log('Channels:', channelInfo)

    // Example: Get user info
    const userInfo = await slack.getUserInfo('U02M3TMTV9B')
    console.log('User info:', userInfo)
  } catch (error: unknown) {
    console.error('Error:', (error as Error).message)
  }
}

main()
