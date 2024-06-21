class_name Sort
# https://en.wikipedia.org/wiki/Merge_sort


## Merge sort with multiple sorting methods. the earlier the callable is in the callable array, the greater weight it has.
static func multi_merge_sort(m: Array, c: Array[Callable]):
	for i in range(len(c)):
		m = merge_sort(m, c[len(c) - i - 1])

static func merge_sort(m: Array, c: Callable):
	# Base case. A list of zero or one elements is sorted, by definition.
	if m.size() <= 1:
		return m

	# Recursive case. First, divide the list into equal-sized sublists
	# consisting of the first half and second half of the list.
	# This assumes lists start at index 0.
	var left = []
	var right = []
	for i in range(m.size()):
		if i < m.size() * 0.5:
			left.append(m[i])
		else:
			right.append(m[i])

	# Recursively sort both sublists.
	left = merge_sort(left, c)
	right = merge_sort(right, c)

	# Then merge the now-sorted sublists.
	return merge(left, right, c)

static func merge(left, right, c):
	var result = []

	while left.size() > 0 and right.size() > 0:
		if c.call(left[0], right[0]):
			result.append(left[0])
			left.remove(0)
		else:
			result.append(right[0])
			right.remove(0)

	# Either left or right may have elements left; consume them.
	# (Only one of the following loops will actually be entered.)
	while left.size() > 0:
		result.append(left[0])
		left.remove(0)
	while right.size() > 0:
		result.append(right[0])
		right.remove(0)
		
	return result

static func driller_component_object_group_sort(a: DrillerComponentObject, b: DrillerComponentObject):
	var group_a: String = a.parent_group_name
	var group_b: String = b.parent_group_name
	return group_a < group_b
	
static func driller_component_object_age_sort(a: DrillerComponentObject, b: DrillerComponentObject):
	var age_a: int = a.in_game_age
	var age_b: int = b.in_game_age
	return age_a < age_b

func driller_component_object_order_found_sort(a: DrillerComponentObject, b: DrillerComponentObject):
	var age_a: int = a.in_game_age
	var age_b: int = b.in_game_age
	return age_a < age_b
