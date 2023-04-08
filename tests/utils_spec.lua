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

  it('should convert an ordered list', function()
    local code_block = {
      version = 1,
      type = 'doc',
      content = {
        {
          type = 'orderedList',
          attrs = {
            order = 1,
          },
          content = {
            {
              type = 'listItem',
              content = {
                {
                  type = 'paragraph',
                  content = {
                    {
                      type = 'text',
                      text = 'Item 1',
                    },
                  },
                },
              },
            },
            {
              type = 'listItem',
              content = {
                {
                  type = 'paragraph',
                  content = {
                    {
                      type = 'text',
                      text = 'Item 2',
                    },
                  },
                },
              },
            },
          },
        },
      },
    }

    local expected = '1. Item 1\n2. Item 2\n\n'
    local actual = utils.convert_adf_to_markdown(code_block)
    assert.are.same(expected, actual)
  end)

  it('should convert a bullet list', function()
    local code_block = {
      version = 1,
      type = 'doc',
      content = {
        {
          type = 'bulletList',
          content = {
            {
              type = 'listItem',
              content = {
                {
                  type = 'paragraph',
                  content = {
                    {
                      type = 'text',
                      text = 'Item 1',
                    },
                  },
                },
              },
            },
            {
              type = 'listItem',
              content = {
                {
                  type = 'paragraph',
                  content = {
                    {
                      type = 'text',
                      text = 'Item 2',
                    },
                  },
                },
              },
            },
          },
        },
      },
    }

    local expected = '* Item 1\n* Item 2\n\n'
    local actual = utils.convert_adf_to_markdown(code_block)
    assert.are.same(expected, actual)
  end)

  it('should convert a rule', function()
    local code_block = {
      version = 1,
      type = 'doc',
      content = {
        {
          type = 'rule',
        },
      },
    }

    local expected = '---\n\n'
    local actual = utils.convert_adf_to_markdown(code_block)
    assert.are.same(expected, actual)
  end)

  it('should convert strong text', function()
    local code_block = {
      version = 1,
      type = 'doc',
      content = {
        {
          type = 'paragraph',
          content = {
            {
              type = 'text',
              text = 'This is ',
            },
            {
              type = 'text',
              text = 'strong',
              marks = {
                {
                  type = 'strong',
                },
              },
            },
            {
              type = 'text',
              text = ' text',
            },
          },
        },
      },
    }

    local expected = 'This is **strong** text\n'
    local actual = utils.convert_adf_to_markdown(code_block)
    assert.are.same(expected, actual)
  end)

  it('should convert em text', function()
    local code_block = {
      version = 1,
      type = 'doc',
      content = {
        {
          type = 'paragraph',
          content = {
            {
              type = 'text',
              text = 'This is ',
            },
            {
              type = 'text',
              text = 'emphasized',
              marks = {
                {
                  type = 'em',
                },
              },
            },
            {
              type = 'text',
              text = ' text',
            },
          },
        },
      },
    }

    local expected = 'This is *emphasized* text\n'
    local actual = utils.convert_adf_to_markdown(code_block)
    assert.are.same(expected, actual)
  end)

  it('should convert code text', function()
    local code_block = {
      version = 1,
      type = 'doc',
      content = {
        {
          type = 'paragraph',
          content = {
            {
              type = 'text',
              text = 'This is ',
            },
            {
              type = 'text',
              text = 'code',
              marks = {
                {
                  type = 'code',
                },
              },
            },
            {
              type = 'text',
              text = ' text',
            },
          },
        },
      },
    }

    local expected = 'This is `code` text\n'
    local actual = utils.convert_adf_to_markdown(code_block)
    assert.are.same(expected, actual)
  end)

  it('should convert a link', function()
    local code_block = {
      version = 1,
      type = 'doc',
      content = {
        {
          type = 'paragraph',
          content = {
            {
              type = 'text',
              text = 'This is a ',
            },
            {
              type = 'text',
              text = 'link',
              marks = {
                {
                  type = 'link',
                  attrs = {
                    href = 'https://www.google.com',
                  },
                },
              },
            },
            {
              type = 'text',
              text = ' to google',
            },
          },
        },
      },
    }

    local expected = 'This is a [link](https://www.google.com) to google\n'
    local actual = utils.convert_adf_to_markdown(code_block)
    assert.are.same(expected, actual)
  end)

  it('should convert strikethrough text', function()
    local code_block = {
      version = 1,
      type = 'doc',
      content = {
        {
          type = 'paragraph',
          content = {
            {
              type = 'text',
              text = 'This is ',
            },
            {
              type = 'text',
              text = 'strikethrough',
              marks = {
                {
                  type = 'strike',
                },
              },
            },
            {
              type = 'text',
              text = ' text',
            },
          },
        },
      },
    }

    local expected = 'This is ~~strikethrough~~ text\n'
    local actual = utils.convert_adf_to_markdown(code_block)
    assert.are.same(expected, actual)
  end)

  it('should convert multiple marks', function()
    local code_block = {
      version = 1,
      type = 'doc',
      content = {
        {
          type = 'paragraph',
          content = {
            {
              type = 'text',
              text = 'This is ',
            },
            {
              type = 'text',
              text = 'strong and underlined',
              marks = {
                {
                  type = 'strong',
                },
                {
                  type = 'underline',
                },
              },
            },
            {
              type = 'text',
              text = ' text',
            },
          },
        },
      },
    }

    local expected = 'This is **__strong and underlined__** text\n'
    local actual = utils.convert_adf_to_markdown(code_block)
    assert.are.same(expected, actual)
  end)

  it('should convert emoji', function()
    local code_block = {
      version = 1,
      type = 'doc',
      content = {
        {
          type = 'paragraph',
          content = {
            {
              type = 'text',
              text = 'This is ',
            },
            {
              type = 'emoji',
              attrs = {
                shortName = ':smile:',
                text = '😄',
              },
            },
            {
              type = 'text',
              text = ' text',
            },
          },
        },
      },
    }

    local expected = 'This is 😄 text\n'
    local actual = utils.convert_adf_to_markdown(code_block)
    assert.are.same(expected, actual)
  end)

  it('should convert a mention', function()
    local code_block = {
      version = 1,
      type = 'doc',
      content = {
        {
          type = 'paragraph',
          content = {
            {
              type = 'text',
              text = 'This is a ',
            },
            {
              type = 'mention',
              attrs = {
                id = '123',
                text = '@John Doe',
              },
            },
            {
              type = 'text',
              text = ' mention',
            },
          },
        },
      },
    }

    local expected = 'This is a @John Doe mention\n'
    local actual = utils.convert_adf_to_markdown(code_block)
    assert.are.same(expected, actual)
  end)

  it('should convert a date', function()
    local code_block = {
      version = 1,
      type = 'doc',
      content = {
        {
          type = 'paragraph',
          content = {
            {
              type = 'text',
              text = 'This is a ',
            },
            {
              type = 'date',
              attrs = {
                timestamp = '2019-01-01T00:00:00.000Z',
              },
            },
            {
              type = 'text',
              text = ' date',
            },
          },
        },
      },
    }

    local expected = 'This is a 2019-01-01T00:00:00.000Z date\n'
    local actual = utils.convert_adf_to_markdown(code_block)
    assert.are.same(expected, actual)
  end)

  it('should convert a hard break', function()
    local code_block = {
      version = 1,
      type = 'doc',
      content = {
        {
          type = 'paragraph',
          content = {
            {
              type = 'text',
              text = 'This is a ',
            },
            {
              type = 'hardBreak',
            },
            {
              type = 'text',
              text = ' hard break',
            },
          },
        },
      },
    }

    local expected = 'This is a \n hard break\n'
    local actual = utils.convert_adf_to_markdown(code_block)
    assert.are.same(expected, actual)
  end)

  it('should convert an inline card', function()
    local code_block = {
      version = 1,
      type = 'doc',
      content = {
        {
          type = 'paragraph',
          content = {
            {
              type = 'text',
              text = 'This is an ',
            },
            {
              type = 'inlineCard',
              attrs = {
                url = 'https://www.google.com',
              },
            },
            {
              type = 'text',
              text = ' inline card',
            },
          },
        },
      },
    }

    local expected = 'This is an <https://www.google.com> inline card\n'
    local actual = utils.convert_adf_to_markdown(code_block)
    assert.are.same(expected, actual)
  end)
end)
