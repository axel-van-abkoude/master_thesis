def yn() -> bool:
	options = {
		"y": True,
		"yes": True,
		"n": False,
		"no": False,
	}
	answer = input("(y/n):").strip().lower()
	while not answer in options.keys():
		answer = input("Please enter (y/n):").strip().lower()
	return options.get(answer)
