import { Pipe, PipeTransform, SecurityContext } from "@angular/core";
import { DomSanitizer, SafeHtml, SafeResourceUrl, SafeScript, SafeStyle, SafeUrl } from "@angular/platform-browser";

@Pipe({
    name: 'safe',
    standalone: true,
})
export class SafePipe implements PipeTransform {
    //*************************************************************************
    //  Component Life-Cycle Methods
    //*************************************************************************
    constructor(
        private readonly sanitizer: DomSanitizer
    ) {
        // Intentionally blank
    }

    //*************************************************************************
    //  Public Methods
    //*************************************************************************
    public transform(value: any, type: 'html' | 'style' | 'script' | 'url' | 'resourceUrl'): null | SafeHtml | SafeStyle | SafeScript | SafeUrl | SafeResourceUrl {
        switch (type) {
            case 'html': return this.sanitizer.sanitize(SecurityContext.HTML, value);
            case 'style': return this.sanitizer.sanitize(SecurityContext.STYLE, value);
            case 'script': return this.sanitizer.sanitize(SecurityContext.SCRIPT, value);
            case 'url': return this.sanitizer.sanitize(SecurityContext.URL, value);
            case 'resourceUrl': return this.sanitizer.sanitize(SecurityContext.RESOURCE_URL, value);
            default: return null;
        }
    }
}