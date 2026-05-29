set -e

gnome-terminal \
  --class=exit-hyprland-pass \
  --title="Exit-hyprland-pass" \
  -- sh -c '
    clear
    echo "====================================="
    echo "   ⚠️  Exit Hyprland Confirmation ⚠️"
    echo "====================================="
    echo
    read -rp "Are you sure you want to exit Hyprland? [y/N]: " ans
    case "$ans" in
        [Yy]*)
            echo "Exiting..."
            sleep 0.5
            hyprctl dispatch exit
	          systemctl poweroff
            ;;
        *)
            echo "Cancelled."
            ;;
    esac
  '
