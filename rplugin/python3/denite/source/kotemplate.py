"""
FILE: kotemplate.vim
AUTHOR: koturn <jeak.koutan.apple@gmail.com>
DESCRIPTION: {{{
koturn's template loader.
This file is a extension for unite.vim and provides denite-source.
denite.nvim: https://github.com/Shougo/denite.nvim
}}}
"""

from .base import Base


class Source(Base):
    def __init__(self, vim):
        super().__init__(vim)
        self.name = 'kotemplate'
        self.kind = 'kotemplate'

    def on_init(self, context):
        context['__candidates'] = self.vim.call('kotemplate#complete_load', '', '', 0)

    def gather_candidates(self, context):
        return list(map(lambda filepath: {'word': filepath}, context['__candidates']))
