const Topic = struct { value: []const u8, creator: []const u8, last_set: u32 };
const Purpose = struct { value: []const u8, creator: []const u8, last_set: u32 };
const ResponseMetadata = struct { next_cursor: []const u8 };
const Channel = struct {
    id: []const u8,
    name: []const u8,
    is_channel: bool,
    is_group: bool,
    is_im: bool,
    created: u64,
    creator: []const u8,
    is_archived: bool,
    is_general: bool,
    unlinked: u8,
    name_normalized: []const u8,
    is_shared: bool,
    is_ext_shared: bool,
    is_org_shared: bool,
    pending_shared: [][]const u8,
    is_pending_ext_shared: bool,
    is_member: bool,
    is_private: bool,
    is_mpim: bool,
    updated: u64,
    topic: Topic,
    purpose: Purpose,
    previous_names: [][]const u8,
    num_members: u32,
};

pub const Channels = struct { ok: bool, channels: []Channel, response_metadata: ResponseMetadata };
