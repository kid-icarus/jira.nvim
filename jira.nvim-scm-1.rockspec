local _MODREV, _SPECREV = 'scm', '-1'
rockspec_format = '3.0'
package = 'jira.nvim'
version = _MODREV .. _SPECREV

description = {
  summary = 'Jira integration for Neovim',
  labels = { 'neovim' },
  detailed = [[
      jira.nvim: interact with Jira from Neovim, using the Jira REST API.
   ]],
  homepage = 'http://github.com/kid-icarus/jira.nvim',
  license = 'MIT/X11',
}

dependencies = {
  'lua >= 5.1, < 5.4',
}

source = {
  url = 'git://github.com/kid-icarus/jira.nvim',
}
