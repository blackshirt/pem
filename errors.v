module pem

enum PemError {
	mismatched_tags
	malformed_framing
	missing_begin_tag
	missing_end_tag
	missing_data
	invalid_data
	not_utf8
}

fn (e PemError) str() string {
	return match e {
		.mismatched_tags { 'Mismathed Tags' }
		.malformed_framing { 'Malformed Framing' }
		.missing_begin_tag { 'Missing Begin Tag' }
		.missing_end_tag { 'Missing End Tag' }
		.missing_data { 'Missing Data' }
		.invalid_data { 'Invalid Data' }
		.not_utf8 { 'Not utf8' }
		// else {"Unknown error"}
	}
}
