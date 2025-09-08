#!/bin/bash
mode=$(i3-msg -t get_tree | jq -r '
  def find_focused(parent):
    . as $node
    | if ($node.focused == true)
        then {parent: parent, node: $node}
        else ($node.nodes // [] | map(find_focused($node)) | .[])
      end;
  find_focused(null)
  | .parent.layout
')
case "$mode" in
  splith) echo " ↠ " ;;
  splitv) echo " ↡ " ;;
  *) echo "Split: $mode" ;;
esac

