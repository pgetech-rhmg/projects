import { Injectable } from '@angular/core';

import markdownit from 'markdown-it';
import DOMPurify from 'dompurify';

@Injectable({
  providedIn: 'root'
})
export class MarkdownService {

  private readonly md: markdownit = markdownit({
    highlight: null,
    html: false,
    linkify: true,
    breaks: true,
    typographer: true
  });

  constructor() {
  }

  render(markdown: string): string {
    this.md.renderer.rules.html_block = (tokens, idx) => {
      return this.sanitizeHtml(tokens[idx].content);
    };

    this.md.renderer.rules.html_inline = (tokens, idx) => {
      return this.sanitizeHtml(tokens[idx].content);
    };

    return this.md.render(markdown);
  }

  private sanitizeHtml(html: string): string {
    return DOMPurify.sanitize(html, {
      ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br', 'ul', 'ol', 'li', 'code', 'pre'],
      ALLOWED_ATTR: ['href', 'target', 'rel']
    });
  }

}

