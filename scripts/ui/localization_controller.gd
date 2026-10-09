extends Node

var controls: Array[WeakRef] = []


func _ready() -> void:
	_watch(get_parent())
	get_tree().node_added.connect(func(node): _register.call_deferred(node))
	GameLocale.changed.connect(_refresh)


func _watch(node: Node) -> void:
	_register(node)
	for child in node.get_children():
		_watch(child)


func _check_in_shop(node: Node) -> bool:
	var parent: Node = node
	while parent != null:
		if parent.name == "ShopPanel":
			return true
		parent = parent.get_parent()
	return false


func _register(node: Variant) -> void:
	if not is_instance_valid(node) or not get_parent().is_ancestor_of(node) or node.has_meta("locale_manual"):
		return
	if (node is Label or node is RichTextLabel or node is Button) and not node is OptionButton and not node.has_meta("locale_source"):
		node.set_meta("locale_source", str(node.text))
		node.set_meta("locale_output", "")
		node.set_meta("in_shop", _check_in_shop(node))
		controls.append(weakref(node))
		_update(node)


func _refresh() -> void:
	for index in range(controls.size() - 1, -1, -1):
		var node = controls[index].get_ref()
		if node == null:
			controls.remove_at(index)
		else:
			_update(node)


func _update(node: Control) -> void:
	var previous: String = str(node.get_meta("locale_output", ""))
	if str(node.text) != previous:
		node.set_meta("locale_source", str(node.text))
	var in_shop: bool = node.get_meta("in_shop", false)
	var result := GameLocale.display(str(node.get_meta("locale_source")), not in_shop)
	if str(node.text) != result:
		node.text = result
	node.set_meta("locale_output", result)
