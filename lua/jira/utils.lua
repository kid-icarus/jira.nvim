local M = {}

function Set(list)
  local set = {}
  for _, l in ipairs(list) do
    set[l] = true
  end
  return set
end

local dic = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
-- encoding
M.b64encode = function(data)
  return (data:gsub('.', function(x)
    local r, b = '', x:byte()
    for i = 8, 1, -1 do
      r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and '1' or '0')
    end
    return r
  end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
    if #x < 6 then
      return ''
    end
    local c = 0
    for i = 1, 6 do
      c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0)
    end
    return dic:sub(c + 1, c + 1)
  end) .. ({ '', '==', '=' })[#data % 3 + 1]
end

-- All nodes contain a type field
-- all block nodes contain a content field
local top_level_block_nodes = Set {
  'doc',
  'blockquote',
  'bulletList',
  'codeBlock',
  'heading',
  'mediaGroup',
  'mediaSingle',
  'orderedList',
  'panel',
  'paragraph',
  'rule',
  'table',
}

local child_block_nodes = Set {
  'listItem',
  'media',
  'table_cell',
  'table_header',
  'table_row',
}

local inline_nodes = Set {
  'emoji',
  'hardBreak',
  'text',
  'mention',
  'inlineCard',
  'date',
}

local marks = Set {
  'code',
  'em',
  'link',
  'strike',
  'strong',
  'subsup',
  'textColor',
  'underline',
}

-- Converts an ADF to Markdown
-- @param adt ADF table
-- @return Markdown string
local function convert_adf_to_markdown(adt)
  if adt == vim.NIL or not adt then
    return ''
  end
  local md = ''

  local function convert_adf_node_to_markdown(adf_node)
    local node_md = ''

    local top_level_block_nodes_to_markdown = {
      codeBlock = function(node)
        node_md = '```' .. node.attrs.language .. '\n'
        for _, v in ipairs(node.content) do
          node_md = node_md .. convert_adf_node_to_markdown(v)
        end
        node_md = node_md .. '\n```'
        return node_md
      end,
      heading = function(node)
        node_md = ''
        for _, v in ipairs(node.content) do
          node_md = node_md .. convert_adf_node_to_markdown(v)
        end
        return string.rep('#', node.attrs.level) .. ' ' .. node_md
      end,
      blockquote = function(node)
        node_md = ''
        for i, v in ipairs(node.content) do
          node_md = node_md .. '> ' .. convert_adf_node_to_markdown(v)
          if i ~= #node.content then
            node_md = node_md .. '>\n'
          end
        end
        return node_md .. '\n'
      end,
      paragraph = function(node)
        node_md = ''
        for i, v in ipairs(node.content) do
          node_md = node_md .. convert_adf_node_to_markdown(v)
          if i == #node.content then
            node_md = node_md .. '\n'
          end
        end
        return node_md
      end,
      orderedList = function(node)
        node_md = ''
        for i, v in ipairs(node.content) do
          node_md = node_md .. i .. '. ' .. convert_adf_node_to_markdown(v)
        end
        return node_md .. '\n'
      end,
      bulletList = function(node)
        node_md = ''
        for _, v in ipairs(node.content) do
          node_md = node_md .. '* ' .. convert_adf_node_to_markdown(v)
        end
        return node_md .. '\n'
      end,
      listItem = function(node)
        node_md = ''
        for _, v in ipairs(node.content) do
          node_md = node_md .. convert_adf_node_to_markdown(v)
        end
        return node_md
      end,
      taskList = function(node)
        node_md = ''
        for _, v in ipairs(node.content) do
          if v.attrs.state == 'DONE' then
            node_md = node_md .. '* [x] '
          else
            node_md = node_md .. '* [ ] '
          end
          node_md = node_md .. convert_adf_node_to_markdown(v)
        end
        return node_md .. '\n'
      end,
      rule = function()
        return '---\n\n'
      end,
      -- TODO: handle actual media
      mediaGroup = function(node)
        node_md = ''
        for _, v in ipairs(node.content) do
          node_md = node_md .. convert_adf_node_to_markdown(v)
        end
        return node_md
      end,
      mediaSingle = function(node)
        node_md = ''
        for _, v in ipairs(node.content) do
          node_md = node_md .. convert_adf_node_to_markdown(v)
        end
        return node_md
      end,
      media = function(node)
        if node.attrs.type == 'link' then
          return '🔗'
        else
          return '📷'
        end
      end,
    }

    local inline_nodes_to_markdown = {
      emoji = function(node)
        return node.attrs.shortName
      end,
      hardBreak = function()
        return '\n'
      end,
      text = function(node)
        assert(node.text, 'text node must have text field')
        local text_marks = {}
        if not node.marks then
          return node.text
        end
        for _, v in ipairs(adf_node.marks) do
          if v.type == 'link' then
            return node_md .. '[' .. adf_node.text .. '](' .. v.attrs.href .. ')'
            -- links cannot have additonal marks, and should always come first
            -- in the marks array
          elseif v.type == 'strong' then
            text_marks[#text_marks + 1] = '**'
          elseif v.type == 'em' then
            text_marks[#text_marks + 1] = '*'
          elseif v.type == 'strike' then
            text_marks[#text_marks + 1] = '~~'
          elseif v.type == 'code' then
            text_marks[#text_marks + 1] = '`'
          elseif v.type == 'underline' then
            text_marks[#text_marks + 1] = '__'
          end
        end
        return table.concat(text_marks) .. adf_node.text .. table.concat(text_marks):reverse()
      end,
      mention = function(node)
        return '@' .. node.attrs.text
      end,
      inlineCard = function(node)
        return '[' .. node.attrs.url .. '](' .. node.attrs.url .. ')'
      end,
      date = function(node)
        return node.attrs.timestamp
      end,
    }

    if inline_nodes[adf_node.type] then
      node_md = node_md .. inline_nodes_to_markdown[adf_node.type](adf_node)
    elseif top_level_block_nodes_to_markdown[adf_node.type] then
      node_md = node_md .. top_level_block_nodes_to_markdown[adf_node.type](adf_node)
    else
      if not adf_node.content then
        print('Unknown node type: ' .. adf_node.type)
        return node_md
      end
      node_md = ''
      for _, v in ipairs(adf_node.content) do
        node_md = node_md .. convert_adf_node_to_markdown(v)
      end
    end
    return node_md
  end

  for _, v in ipairs(adt.content) do
    md = md .. convert_adf_node_to_markdown(v)
  end
  return md
end

M.convert_adf_to_markdown = convert_adf_to_markdown

-- extract issue id from branch name
-- e.g. feature/ABC-1234
-- e.g. ABC-1234
M.get_issue_id_from_git_branch = function()
  local branch = vim.fn.system 'git rev-parse --abbrev-ref HEAD'
  local issue_id = string.match(branch, '([A-Z]+%-[0-9]+)')
  return issue_id
end

return M
