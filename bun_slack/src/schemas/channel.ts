export interface SlackChannel {
  id: string
  name: string
  is_channel: boolean
  is_group: boolean
  is_im: boolean
  is_mpim: boolean
  is_private: boolean
  created: number
  is_archived: boolean
  is_general: boolean
  unlinked: number
  name_normalized: string
  is_shared: boolean
  is_org_shared: boolean
  is_pending_ext_shared: boolean
  // biome-ignore lint:
  pending_shared: any[]
  context_team_id: string
  updated: number
  parent_conversation: null | string
  creator: string
  is_ext_shared: boolean
  shared_team_ids: string[]
  // biome-ignore lint:
  pending_connected_team_ids: any[]
  is_member: boolean
  topic: {
    value: string
    creator: string
    last_set: number
  }
  purpose: {
    value: string
    creator: string
    last_set: number
  }
  properties: {
    tabs: Array<{
      id?: string
      label?: string
      type: string
      data?: {
        folder_bookmark_id?: string
      }
    }>
    tabz: Array<{
      id?: string
      label?: string
      type: string
      data?: {
        folder_bookmark_id?: string
      }
    }>
  }
  previous_names: string[]
  num_members: number
}

export interface SlackAPIChannelsResponse {
  ok: boolean
  error?: string
  channels: SlackChannel[]
}
