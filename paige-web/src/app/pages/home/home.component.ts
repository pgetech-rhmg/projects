import { Component, ElementRef, NgZone, OnDestroy, OnInit, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';

import { ChatStreamService } from '~/services/chat.service';
import { MarkdownService } from '~/services/markdown.service';

import { BaseComponent } from '~/pages/base.component';

const MAX_HISTORY = 20;

@Component({
    selector: 'home',
    standalone: true,
    imports: [
        CommonModule,
    ],
    templateUrl: './home.component.html',
    styleUrls: ['./home.component.scss']
})

export class HomeComponent extends BaseComponent implements OnInit, OnDestroy {
    @ViewChild('textarea') textareaContainer!: ElementRef<HTMLTextAreaElement>;
    @ViewChild('messagearea') messageareaContainer!: ElementRef<HTMLDivElement>;
    @ViewChild('scroller') scrollerContainer!: ElementRef<HTMLDivElement>;
    @ViewChild('send') sendContainer!: ElementRef<HTMLDivElement>;

    public messages: { type: string, text: string }[] = [];
    public isStreaming: boolean = false;

    private eventSource?: EventSource;
    private scrollPosition: number = 0;

    //*************************************************************************
    //  Component Life-Cycle Methods
    //*************************************************************************
    constructor(
        private readonly zone: NgZone,
        private readonly chatStreamService: ChatStreamService,
        private readonly markdownService: MarkdownService,
    ) {
        super();
    }

    public ngOnInit(): void {
        (async () => {
            await this.initAsync();

            this.textareaContainer.nativeElement.focus();
        })();
    }

    public ngOnDestroy(): void {
        this.eventSource?.close();
    }

    //*************************************************************************
    //  Public Methods
    //*************************************************************************
    public scrolling(event: any): void {
        let messages = this.messageareaContainer.nativeElement;
        let scroller = this.scrollerContainer.nativeElement;

        if (!this.isStreaming) {
            if (this.isAtBottom(messages)) {
                scroller.classList.add('hide');
            } else {
                scroller.classList.remove('hide');
            }
        }
    }

    public scrollToBottom(): void {
        let messages = this.messageareaContainer.nativeElement;

        if (messages) {
            this.scrollPosition = messages.scrollHeight;

            messages.scrollTo({
                top: messages.scrollHeight,
                behavior: 'smooth'
            });
        }
    }

    public autoResize(textarea: HTMLTextAreaElement): void {
        let lineHeight = 25; // must match CSS
        let maxLines = 3;
        let maxHeight = lineHeight * maxLines;

        textarea.style.height = 'auto';

        let newHeight = Math.min(textarea.scrollHeight, maxHeight);

        textarea.style.height = `${newHeight}px`;
        textarea.style.overflowY = textarea.scrollHeight > maxHeight ? 'auto' : 'hidden';

        let send = this.sendContainer.nativeElement;

        if (send) {
            if (textarea.value.trim() === "") {
                send.classList.add('hide');
            } else {
                send.classList.remove('hide');
            }
        }
    }

    public onEnter(event: KeyboardEvent, textarea: HTMLTextAreaElement): void {
        if (event.shiftKey) {
            return;
        }

        event.preventDefault();
        this.sendMessage(textarea.value);

        textarea.value = '';
        this.autoResize(textarea);
    }

    public cancelStream(): void {
        this.eventSource?.close();
        this.eventSource = undefined;

        this.messages.at(-1)!.text += "<br /><br /><strong><i>[Request cancelled by user]</i></strong>";
        this.isStreaming = false;

        setTimeout(() => {
            if (this.textareaContainer) {
                this.textareaContainer.nativeElement.focus();
            }
        }, 100);
    }

    //*************************************************************************
    //  Private Methods
    //*************************************************************************
    private isAtBottom(el: HTMLElement): boolean {
        let threshold = 10;

        return el.scrollTop + el.clientHeight >= el.scrollHeight - threshold;
    }

    private sendMessage(message: string): void {
        if (!message.trim()) {
            return;
        }

        let markdownBuffer = "";
        let rawData = "";

        let messages: { role: string, content: string }[] = [];

        this.messages.slice(-MAX_HISTORY).forEach((msg: any) => {
            let role = msg.type;

            if (role === "system") {
                role = "assistant";
            }

            messages.push({ role: role, content: msg.text });
        })

        this.messages.push(
            { type: "user", text: message },
            { type: "system", text: "..." }
        );

        this.isStreaming = true;

        this.chatStreamService.startChat({ prompt: message, history: messages }).subscribe({
            next: (jobId: any) => {
                this.chatStreamService.setActiveJob(jobId);

                this.eventSource = this.chatStreamService.chatStream(jobId.jobId);

                this.eventSource.onmessage = (event: MessageEvent) => {
                    this.zone.run(() => {
                        if (!event.data) {
                            return;
                        }

                        rawData += event.data;
                        markdownBuffer += event.data;
                        markdownBuffer = this.normalizeTables(markdownBuffer);
                        markdownBuffer = this.wrapTables(markdownBuffer);

                        this.messages.at(-1)!.text = this.markdownService.render(markdownBuffer);

                        this.scrollToBottom();
                    });
                };

                this.eventSource.addEventListener('complete', () => {
                    let msg = this.messages.at(-1)!.text;

                    msg = msg.replaceAll("<a ", "<a target=\"_blank\" ");

                    this.messages.at(-1)!.text = msg;

                    this.isStreaming = false;
                    this.eventSource?.close();

                    setTimeout(() => {
                        if (this.textareaContainer) {
                            this.textareaContainer.nativeElement.focus();
                        }
                    }, 100);
                });

                this.eventSource.onerror = (error: any) => {
                    console.error('SSE error', error);

                    this.messages.at(-1)!.text += `<br /><br /><strong><i>${error}</i></strong>`;
                    this.isStreaming = false;
                    this.eventSource?.close();

                    setTimeout(() => {
                        if (this.textareaContainer) {
                            this.textareaContainer.nativeElement.focus();
                        }
                    }, 100);
                };
            },
            error: (error: any) => {
                console.error('Chat failed:', error);

                this.messages.at(-1)!.text += `<br /><br /><strong><i>${error}</i></strong>`;
                this.isStreaming = false;

                setTimeout(() => {
                    if (this.textareaContainer) {
                        this.textareaContainer.nativeElement.focus();
                    }
                }, 100);
            }
        });

        setTimeout(() => {
            this.scrollToBottom();
        }, 100);
    }

    private normalizeTables(markdown: string): string {
        let result = markdown;

        result = result.replaceAll(/\|\|\s*/g, "|\n|");

        return result;
    }

    private wrapTables(html: string): string {
        return html.replaceAll(
            /<table([\s\S]*?)<\/table>/g,
            (table) => {
                return `
<div class="table-scroll-wrapper">
${table}
</div>`;
            }
        );
    }
}
