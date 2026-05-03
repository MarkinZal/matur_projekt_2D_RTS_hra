@tool
extends EditorScript

func _run() -> void:
	var root = get_scene()
	if not root:
		print("Chyba: Žádná scéna není aktuálně otevřená v editoru.")
		return
		
	var tree_text = "=== SCENE TREE CONTEXT pro AI ===\n"
	tree_text += "Root Node: " + str(root.name) + "\n"
	tree_text += "-----------------------------------\n"
	
	var content = _build_node_string(root, "")
	if content == "":
		print("Varování: Skript vygeneroval prázdný obsah. Zkontroluj případné chyby v Output konzoli dole.")
		
	tree_text += content
	
	DisplayServer.clipboard_set(tree_text)
	print("Úspěch! Strom scény byl zkopírován do schránky (Verze 3.0).")

func _build_node_string(node: Node, indent: String) -> String:
	if not is_instance_valid(node): return ""

	var node_info = indent + "■ " + str(node.name) + " (" + str(node.get_class()) + ")"
	
	var script = node.get_script()
	if script:
		var path = str(script.resource_path)
		if path != "":
			node_info += " [Script: " + path.get_file() + "]"
		else:
			node_info += " [Script: Built-in/Local]"
	
	var result = node_info + "\n"
	var child_indent = indent + "    "
	
	var signals = node.get_signal_list()
	for sig in signals:
		var connections = node.get_signal_connection_list(sig.name)
		for conn in connections:
			var callable = conn.callable
			if callable.is_valid():
				var target_obj = callable.get_object()
				if target_obj:
					# OPRAVA: Nejdřív ověříme, zda má objekt vůbec vlastnost 'name'
					var target_name = ""
					if "name" in target_obj:
						target_name = str(target_obj.name)
					else:
						# Pokud nemá jméno (např. EditorSelection), vypíšeme jeho třídu
						target_name = "[" + str(target_obj.get_class()) + "]"
						
					var method_name = str(callable.get_method())
					if method_name != "":
						result += child_indent + "-> [Signal] " + str(sig.name) + " => " + target_name + "." + method_name + "()\n"
	
	for child in node.get_children(true):
		result += _build_node_string(child, child_indent)
		
	return result
