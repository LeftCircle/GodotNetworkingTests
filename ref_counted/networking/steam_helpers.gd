extends RefCounted
class_name SteamHelpers

static func get_fail_reason(response : int) -> String:
	var fail_reason: String
	match response:
		2:  fail_reason = "This lobby no longer exists."
		3:  fail_reason = "You don't have permission to join this lobby."
		4:  fail_reason = "The lobby is now full."
		5:  fail_reason = "Uh... something unexpected happened!"
		6:  fail_reason = "You are banned from this lobby."
		7:  fail_reason = "You cannot join due to having a limited account."
		8:  fail_reason = "This lobby is locked or disabled."
		9:  fail_reason = "This lobby is community locked."
		10: fail_reason = "A user in the lobby has blocked you from joining."
		11: fail_reason = "A user you have blocked is in the lobby."
	return fail_reason
