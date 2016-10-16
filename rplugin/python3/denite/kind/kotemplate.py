"""
FILE: kotemplate.vim
AUTHOR: koturn <jeak.koutan.apple@gmail.com>
DESCRIPTION: {{{
koturn's template loader.
This file is a extension for unite.vim and provides denite-kind.
denite.nvim: https://github.com/Shougo/denite.nvim
}}}
"""

from .base import Base


class Kind(Base):
    def __init__(self, vim):
        super().__init__(vim)
        self.name = 'kotemplate'

    def action_default(self, context):
        for target in context['targets']:
            self.vim.call('kotemplate#load', target['word'])
