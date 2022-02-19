module pem

import encoding.base64

// parse parses a single PEM-encoded data from array of byte to Pem struct.
pub fn parse(input []byte) ?Pem {
	b := parse_block(input) ?
	pem := new_from_block(b) ?
	return pem
}

// parse_many parses a set of PEM-encoded data array of bytes to sets of Pems struct
pub fn parse_many(input []byte) ?[]Pem {
	block := parse_block_iterator(input) ? // blockmatches

	mut pems := []Pem{}
	for item in block {
		pem := new_from_block(item) ?
		pems << pem
	}
	return pems
}

fn new_from_block(b Block) ?Pem {
	tag := b.begin
	if tag.len == 0 {
		return error(PemError.missing_begin_tag.str())
	}

	tag_end := b.end
	if tag_end.len == 0 {
		return error(PemError.missing_end_tag.str())
	}

	if tag != tag_end {
		return error(PemError.mismatched_tags.str())
	}
	mut pem := Pem{
		tag: tag.bytestr()
		contents: b.data
	}
	pem.strip_eol_from_data()
	// If they did, then we can grab the data section
	raw_data := pem.contents.bytestr()

	// and decode it from base64 into a byte array
	contents := base64.decode(raw_data)

	pem.contents = contents
	return pem
}

fn (mut p Pem) strip_eol_from_data() Pem {
	p.contents = p.contents.filter(!it.is_space())
	return p
}
