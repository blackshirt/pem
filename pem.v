module pem

const (
	begin_tag   = '-----BEGIN '
	end_tag     = '-----END '
	dash_marker = '-----'

	line_wrap   = 64

	char_nul    = byte(0x00)
	char_htb    = byte(0x09)
	char_spc    = byte(0x20)
	char_cr     = byte(0x0d) // \r
	char_lf     = byte(0x0a) // \n
	char_cln    = byte(0x3A)

	null_bytes  = []byte{len: 0, cap: 0}
)

// block data
struct Block {
mut:
	begin []byte
	data  []byte
	end   []byte
}

struct BlockMatches {
mut:
	input []byte
}

pub enum LineEnding {
	crlf
	lf
}

pub struct EncodeConfig {
	line_ending LineEnding
}

// formated data
pub struct Pem {
mut:
	tag      string
	contents []byte
}

fn parse_block(input []byte) ?Block {
	block, _ := parse_inner(input) ?
	return block
}

// parse_block_iterator return BlockMatches iterator generator,
// used by parse_many for parse multi block data
fn parse_block_iterator(input []byte) ?BlockMatches {
	return BlockMatches{input}
}

// next makes BlockMatches act as iterator, in for loop
fn (mut b BlockMatches) next() ?Block {
	if b.input.len == 0 {
		return none
	}

	if b.input.len > 0 {
		block, remaining := parse_inner(b.input) ?
		b.input = remaining
		return block
	}
	return none
}

fn parse_inner(src []byte) ?(Block, []byte) {
	// mut input := s.clone()
	mut input := []byte{}
	mut data := []byte{}
	mut begin := []byte{}

	input, _ = read_until(src, pem.begin_tag.bytes())
	input, begin = read_until(input, pem.dash_marker.bytes())

	input = skip_whitespace(input)
	input, data = read_until(input, pem.end_tag.bytes())
	mut remaining, end := read_until(input, pem.dash_marker.bytes())

	remaining = skip_whitespace(remaining)
	block := Block{
		begin: begin
		data: data
		end: end
	}
	return block, remaining
}

fn skip_whitespace(data []byte) []byte {
	mut input := data.clone()
	for input.len > 0 {
		b := input.first()
		if b in [pem.char_spc, pem.char_lf, pem.char_cr] {
			input = input[1..]
		} else {
			break
		}
	}
	return input
}

// read_until returns the remaining input (after the secondary matched string) and the matched data
// return remaining, matched
fn read_until(input []byte, marker []byte) ([]byte, []byte) {
	if marker.len == 0 {
		return []byte{}, input
	}
	mut index := 0
	mut found := 0

	for input.len - index >= marker.len - found {
		if input[index] == marker[found] {
			found += 1
		} else {
			found = 0
		}
		index += 1
		if found == marker.len {
			remaining := input[index..]
			matched := input[..index - found]
			return remaining, matched
		}
	}
	return pem.null_bytes, pem.null_bytes
}
