local utils = require 'jira.utils'

describe('convert_adf_to_markdown', function()
  it('should convert a simple paragraph', function()
    local adf = {
      type = 'paragraph',
      content = {
        {
          type = 'text',
          text = 'This is a paragraph',
        },
      },
    }
    local expected = 'This is a paragraph'
    local actual = utils.convert_adf_to_markdown(adf)
    assert.are.same(expected, actual)
  end)

  it('should convert a code block', function()
    local code_block = {
      version = 1,
      type = 'doc',
      content = {
        {
          type = 'codeBlock',
          attrs = {
            language = 'typescript',
          },
          content = { {
            type = 'text',
            text = "import {foo} from './foo'",
          } },
        },
      },
    }
    local expected = "```typescript\nimport {foo} from './foo'\n```"
    local actual = utils.convert_adf_to_markdown(code_block)
    assert.are.same(expected, actual)
  end)

  it('should convert a heading level 1', function()
    local code_block = {
      version = 1,
      type = 'doc',
      content = {
        {
          type = 'heading',
          attrs = {
            level = 1,
          },
          content = { {
            type = 'text',
            text = 'Heading 1',
          } },
        },
      },
    }

    local expected = '# Heading 1'
    local actual = utils.convert_adf_to_markdown(code_block)
    assert.are.same(expected, actual)
  end)

  it('should convert a heading level 2', function()
    local code_block = {
      version = 1,
      type = 'doc',
      content = {
        {
          type = 'heading',
          attrs = {
            level = 2,
          },
          content = { {
            type = 'text',
            text = 'Heading 2',
          } },
        },
      },
    }

    local expected = '## Heading 2'
    local actual = utils.convert_adf_to_markdown(code_block)
    assert.are.same(expected, actual)
  end)

  it('should convert a heading level 3', function()
    local code_block = {
      version = 1,
      type = 'doc',
      content = {
        {
          type = 'heading',
          attrs = {
            level = 3,
          },
          content = { {
            type = 'text',
            text = 'Heading 3',
          } },
        },
      },
    }

    local expected = '### Heading 3'
    local actual = utils.convert_adf_to_markdown(code_block)
    assert.are.same(expected, actual)
  end)

  it('should convert a heading level 4', function()
    local code_block = {
      version = 1,
      type = 'doc',
      content = {
        {
          type = 'heading',
          attrs = {
            level = 4,
          },
          content = { {
            type = 'text',
            text = 'Heading 4',
          } },
        },
      },
    }

    local expected = '#### Heading 4'
    local actual = utils.convert_adf_to_markdown(code_block)
    assert.are.same(expected, actual)
  end)

  it('should convert a heading level 5', function()
    local code_block = {
      version = 1,
      type = 'doc',
      content = {
        {
          type = 'heading',
          attrs = {
            level = 5,
          },
          content = { {
            type = 'text',
            text = 'Heading 5',
          } },
        },
      },
    }

    local expected = '##### Heading 5'
    local actual = utils.convert_adf_to_markdown(code_block)
    assert.are.same(expected, actual)
  end)

  it('should convert a heading level 6', function()
    local code_block = {
      version = 1,
      type = 'doc',
      content = {
        {
          type = 'heading',
          attrs = {
            level = 6,
          },
          content = { {
            type = 'text',
            text = 'Heading 6',
          } },
        },
      },
    }

    local expected = '###### Heading 6'
    local actual = utils.convert_adf_to_markdown(code_block)
    assert.are.same(expected, actual)
  end)

  it('should convert a blockquote', function()
    local code_block = {
      version = 1,
      type = 'doc',
      content = {
        {
          type = 'blockquote',
          content = {
            {
              type = 'paragraph',
              content = {
                {
                  type = 'text',
                  text = 'This is a blockquote',
                },
              },
            },
            {
              type = 'paragraph',
              content = { {
                type = 'text',
                text = 'Moar text',
              } },
            },
          },
        },
      },
    }

    local expected = '> This is a blockquote\n>\n> Moar text\n\n'
    local actual = utils.convert_adf_to_markdown(code_block)
    assert.are.same(expected, actual)
  end)
end)
