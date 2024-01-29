local wezterm = require 'wezterm'

local function basename(s)
  return s:gsub('(.*[/\\])(.*)', '%2'):match('%w+')
end

local function is_not_empty(s)
  return s ~= nil and #tostring(s) > 0
end

local function remove_trailing(s)
  if string.sub(s, -1, -1) == "/" then
    return string.sub(s, 1, -2)
  end

  return s
end

local function get_current_process(tab)
  local wezterm_prog = tab.active_pane.user_vars.WEZTERM_PROG
  if is_not_empty(wezterm_prog) then
    return basename(wezterm_prog)
  end

  if is_not_empty(tab.active_pane.foreground_process_name) then
    return basename(tab.active_pane.foreground_process_name)
  end

  return '?'
end

local function get_current_working_dir(tab)
  local current_dir_url = tab.active_pane.current_working_dir
  if not is_not_empty(current_dir_url) then
    return ' ?'
  end

  local home_dir = remove_trailing(os.getenv('HOME')) .. '/'
  if current_dir_url.file_path == home_dir then
    return ' ~'
  end

  return ' ' .. current_dir_url.file_path:gsub('(.*/)(.*)/', '%2')
end

wezterm.on(
  'format-tab-title',
  function(tab, tabs, panes, config, hover, max_width)
    local idx = ' ' .. tab.tab_index + 1 .. ' '
    local process = '[' .. get_current_process(tab) .. ']'
    local dir = get_current_working_dir(tab)
    local separator = ' ▕'

    return {
      { Attribute = { Intensity = 'Bold' } },
      { Text = idx },
      'ResetAttributes',
      { Foreground = { Color = '#9cdbfb' } },
      { Text = process },
      'ResetAttributes',
      { Text = wezterm.truncate_right(dir, max_width - (2 + #idx + #process)) },
      { Attribute = { Intensity = 'Bold' } },
      { Foreground = { Color = '#1b2226' } },
      { Text = separator }
    }
  end
)

wezterm.on(
  'format-window-title',
  function(tab, _, tabs)
    local index = ''
    if #tabs > 1 then
      index = '[' .. tab.tab_index + 1 .. '/' .. #tabs .. ']'
    end

    return index .. tab.window_title
  end
)

return {
  colors = {
    tab_bar = {
      background = '#283237',
      active_tab = {
        bg_color = '#1b2226',
        fg_color = '#cccccc'
      },
      inactive_tab = {
        bg_color = '#283237',
        fg_color = '#cccccc'
      },
      new_tab = {
        bg_color = '#283237',
        fg_color = '#cccccc'
      },
      inactive_tab_hover = {
        bg_color = '#1b2226',
        fg_color = '#cccccc'
      },
      new_tab_hover = {
        bg_color = '#1b2226',
        fg_color = '#cccccc'
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

      selection_bg = 'rgba(128, 203, 196, 12.55%)',
      selection_fg = 'none',

      scrollbar_thumb = 'rgba(84, 110, 122, 50%)',

      ansi = {
        '#000000',
        '#e0787b',
        '#cae797',
        '#f7cd7a',
        '#8aa9f9',
        '#bf94e4',
        '#9cdbfb',
        '#ffffff'
      },
      brights = {
        '#546e7a',
        '#e0787b',
        '#cae797',
        '#f7cd7a',
        '#8aa9f9',
        '#bf94e4',
        '#9cdbfb',
        '#ffffff'
      }
    }
  },
  enable_scroll_bar = true,
  font = wezterm.font 'MesloLGS Nerd Font Mono',
  font_size = 13.0,
  line_height = 1.05,
  tab_bar_at_bottom = true,
  tab_max_width = 48,
  use_fancy_tab_bar = false,
  window_close_confirmation = 'NeverPrompt',
  window_padding = {
    bottom = '0.25cell',
    left = '1cell',
    right = '1cell',
    top = '0.25cell'
  }
}
