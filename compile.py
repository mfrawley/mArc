import re 
wsRegex =re.compile("(^[\s\t]+)")

def level(line):
	return len(wsRegex.findall(line))
	
def appendParens(line, count):
	return line + ''.join([')' for p in range(count)])

def prependWhitespace(count):
	return " ".join([' ' for x in range(count)])
	
def compile(filename):
	"""
	For any non-empty line
	Prepend a '(', and increment count of ')'s to insert.
	If we reach an empty line, append all closing parens to previous line. 
	Reset counter.
	"""
	f = open(filename,'r')
	parenCount=0
	lines = f.read().split('\n')
	i=0
	length = len(lines)
	for line in lines:
		realChars = line.lstrip()
		#Process any non-empty lines, ignoring whitespace
		if len(realChars) > 0:
			#if you open it, you close it
			if realChars[0] != '(':
				lines[i] = prependWhitespace(level(line)) + '('+realChars
				parenCount+=1
			else:
				lines[i] = prependWhitespace(level(line)) + realChars
		else:
			#add parens to preceding block whenever we encounter a subsequent empty line
			if i > 0:
				lines[i-1] = appendParens(lines[i-1], parenCount)
				parenCount = 0
				
		#if it's the last line, close any pending parens
		if i == length-1:
			lines[i] = appendParens(lines[i], parenCount)
			parenCount=0		

		i=i+1

	return '\n'.join(lines)

	
print compile('test.mrc')