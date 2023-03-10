local wezterm = require 'wezterm'

wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
    local index = ''
    if #tabs > 1 then
        index = string.format('[%d/%d] ', tab.tab_index + 1, #tabs)
    end

    return index .. tab.window_title
end)

return {
    colors = {
        tab_bar = {
            active_tab = {
                bg_color = '#1b2226',
                fg_color = '#cccccc',
            }
        }
    },
    color_scheme = 'Material Oceanic',
    color_schemes = {
        ['Material Oceanic'] = {
            background = '#1b2226',
            foreground = '#cccccc',

            cursor_bg = '#f7cd7a',
            cursor_fg = '#1b2226',
            cursor_border = '#f7cd7a',

            selection_bg = '#222c2f',
            selection_fg = 'none',

            scrollbar_thumb = 'rgba(204, 204, 204, 50%)',

            ansi = {'#000000', '#e0787b', '#cae797', '#f7cd7a', '#8aa9f9', '#bf94e4', '#9cdbfb', '#ffffff'},
            brights = {'#546e7a', '#e0787b', '#cae797', '#f7cd7a', '#8aa9f9', '#bf94e4', '#9cdbfb', '#ffffff'}
        }
    },
    enable_scroll_bar = true,
    font = wezterm.font 'MesloLGS Nerd Font Mono',
    font_size = 13.0,
    line_height = 1.05,
    -- tab_max_width = 48,
    -- use_fancy_tab_bar = false,
    window_padding = {
        bottom = '0.25cell',
        left = '1cell',
        right = '1cell',
        top = '0.25cell'
    }
}
