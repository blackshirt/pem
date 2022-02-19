module pem

import strings
import encoding.base64

// encode encodes a Pem struct into a PEM-encoded string
pub fn encode(pem Pem) string {
	return encode_config(pem, EncodeConfig{
		line_ending: LineEnding.crlf
	})
}

// encode_many encodes multiple Pem structs into a PEM-encoded data string
pub fn encode_many(pems []Pem) string {
	encoded_pems := pems.map(encode(it))

	res := encoded_pems.join('\r\n')
	return res
}

// encode_many_config encodes multiple PEM structs into a PEM-encoded data string
// with additional configuration options
pub fn encode_many_config(pems []Pem, config EncodeConfig) string {
	line_ending := match config.line_ending {
		.crlf { '\r\n' }
		.lf { '\n' }
	}
	encoded_pems := pems.map(encode_config(it, config))
	res := encoded_pems.join(line_ending)
	return res
}

fn encode_config(pem Pem, config EncodeConfig) string {
	line_ending := match config.line_ending {
		.crlf { '\r\n' }
		.lf { '\n' }
	}

	mut output := strings.new_builder(1024) ///TODO: makes it configurable
	mut contents := ''
	if pem.contents.len == 0 {
		contents = base64.encode_str('')
	} else {
		contents = base64.encode(pem.contents)
	}
	output.write_string('-----BEGIN $pem.tag-----$line_ending')

	for c in chunk(contents, 64) {
		output.write_string('$c$line_ending')
	}
	output.write_string('-----END $pem.tag-----$line_ending')

	return output.str()
}

// copied and adapted from arrays.chunk
fn chunk(src string, size int) []string {
	// allocate chunk array
	mut chunks := []string{cap: src.len / size + if src.len % size == 0 { 0 } else { 1 }}

	for i := 0; true; {
		// check chunk size is greater than remaining element size
		if src.len < i + size {
			// check if there's no more element to chunk
			if src.len <= i {
				break
			}
			chunks << src[i..]
			break
		}
		chunks << src[i..i + size]
		i += size
	}

	return chunks
}
