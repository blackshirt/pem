module pem

const sample_lf = '-----BEGIN RSA PRIVATE KEY-----
MIIBPQIBAAJBAOsfi5AGYhdRs/x6q5H7kScxA0Kzzqe6WI6gf6+tc6IvKQJo5rQc
dWWSQ0nRGt2hOPDO+35NKhQEjBQxPh/v7n0CAwEAAQJBAOGaBAyuw0ICyENy5NsO
2gkT00AWTSzM9Zns0HedY31yEabkuFvrMCHjscEF7u3Y6PB7An3IzooBHchsFDei
AAECIQD/JahddzR5K3A6rzTidmAf1PBtqi7296EnWv8WvpfAAQIhAOvowIXZI4Un
DXjgZ9ekuUjZN+GUQRAVlkEEohGLVy59AiEA90VtqDdQuWWpvJX0cM08V10tLXrT
TTGsEtITid1ogAECIQDAaFl90ZgS5cMrL3wCeatVKzVUmuJmB/VAmlLFFGzK0QIh
ANJGc7AFk4fyFD/OezhwGHbWmo/S+bfeAiIh2Ss2FxKJ
-----END RSA PRIVATE KEY-----

-----BEGIN RSA PUBLIC KEY-----
MIIBOgIBAAJBAMIeCnn9G/7g2Z6J+qHOE2XCLLuPoh5NHTO2Fm+PbzBvafBo0oYo
QVVy7frzxmOqx6iIZBxTyfAQqBPO3Br59BMCAwEAAQJAX+PjHPuxdqiwF6blTkS0
RFI1MrnzRbCmOkM6tgVO0cd6r5Z4bDGLusH9yjI9iI84gPRjK0AzymXFmBGuREHI
sQIhAPKf4pp+Prvutgq2ayygleZChBr1DC4XnnufBNtaswyvAiEAzNGVKgNvzuhk
ijoUXIDruJQEGFGvZTsi1D2RehXiT90CIQC4HOQUYKCydB7oWi1SHDokFW2yFyo6
/+lf3fgNjPI6OQIgUPmTFXciXxT1msh3gFLf3qt2Kv8wbr9Ad9SXjULVpGkCIB+g
RzHX0lkJl9Stshd/7Gbt65/QYq+v+xvAeT0CoyIg
-----END RSA PUBLIC KEY-----
'

const crlf_sample = '-----BEGIN RSA PRIVATE KEY-----\r
MIIBPQIBAAJBAOsfi5AGYhdRs/x6q5H7kScxA0Kzzqe6WI6gf6+tc6IvKQJo5rQc\r
dWWSQ0nRGt2hOPDO+35NKhQEjBQxPh/v7n0CAwEAAQJBAOGaBAyuw0ICyENy5NsO\r
2gkT00AWTSzM9Zns0HedY31yEabkuFvrMCHjscEF7u3Y6PB7An3IzooBHchsFDei\r
AAECIQD/JahddzR5K3A6rzTidmAf1PBtqi7296EnWv8WvpfAAQIhAOvowIXZI4Un\r
DXjgZ9ekuUjZN+GUQRAVlkEEohGLVy59AiEA90VtqDdQuWWpvJX0cM08V10tLXrT\r
TTGsEtITid1ogAECIQDAaFl90ZgS5cMrL3wCeatVKzVUmuJmB/VAmlLFFGzK0QIh\r
ANJGc7AFk4fyFD/OezhwGHbWmo/S+bfeAiIh2Ss2FxKJ\r
-----END RSA PRIVATE KEY-----\r
\r
-----BEGIN RSA PUBLIC KEY-----\r
MIIBOgIBAAJBAMIeCnn9G/7g2Z6J+qHOE2XCLLuPoh5NHTO2Fm+PbzBvafBo0oYo\r
QVVy7frzxmOqx6iIZBxTyfAQqBPO3Br59BMCAwEAAQJAX+PjHPuxdqiwF6blTkS0\r
RFI1MrnzRbCmOkM6tgVO0cd6r5Z4bDGLusH9yjI9iI84gPRjK0AzymXFmBGuREHI\r
sQIhAPKf4pp+Prvutgq2ayygleZChBr1DC4XnnufBNtaswyvAiEAzNGVKgNvzuhk\r
ijoUXIDruJQEGFGvZTsi1D2RehXiT90CIQC4HOQUYKCydB7oWi1SHDokFW2yFyo6\r
/+lf3fgNjPI6OQIgUPmTFXciXxT1msh3gFLf3qt2Kv8wbr9Ad9SXjULVpGkCIB+g\r
RzHX0lkJl9Stshd/7Gbt65/QYq+v+xvAeT0CoyIg\r
-----END RSA PUBLIC KEY-----\r
'

fn test_encode_empty_contents() ? {
	pem := Pem{
		tag: 'FOO'
		contents: []byte{}
	}
	encoded := encode(pem)
	assert encoded != ''
	pem_out := parse(encoded.bytes()) ?
	assert pem == pem_out
}

fn test_encode_with_contents() ? {
	pem := Pem{
		tag: 'FOO'
		contents: [byte(0x1), 0x2, 0x3, 0x4]
	}
	encoded := encode(pem)

	assert encoded != ''

	pem_out := parse(encoded.bytes()) ?
	assert pem == pem_out
}

fn test_encode_many() ? {
	pems := parse_many(pem.crlf_sample.bytes()) ?
	encoded := encode_many(pems)

	assert pem.crlf_sample == encoded
}

fn test_encode_config_contents() ? {
	pem := Pem{
		tag: 'FOO'
		contents: [byte(1), 2, 3, 4]
	}
	config := EncodeConfig{
		line_ending: LineEnding.lf
	}
	encoded := encode_config(pem, config)
	assert encoded != ''

	pem_out := parse(encoded.bytes()) ?
	assert pem == pem_out
}

fn test_encode_many_config() ? {
	pems := parse_many(pem.sample_lf.bytes()) ?
	config := EncodeConfig{
		line_ending: LineEnding.lf
	}
	encoded := encode_many_config(pems, config)

	assert pem.sample_lf == encoded
}
