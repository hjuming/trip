import { Injectable, LOCALE_ID, Inject } from '@angular/core';

export interface Language {
  code: string;
  name: string;
  nativeName: string;
}

@Injectable({
  providedIn: 'root',
})
export class LanguageService {
  readonly languages: Language[] = [
    { code: 'en', name: 'English', nativeName: 'English' },
    { code: 'zh-Hant', name: 'Traditional Chinese', nativeName: '繁體中文' },
  ];

  constructor(@Inject(LOCALE_ID) public currentLocale: string) {}

  getCurrentLanguage(): Language {
    return this.languages.find((lang) => lang.code === this.currentLocale) || this.languages[0];
  }

  switchLanguage(langCode: string): void {
    const baseHref = document.querySelector('base')?.href || '/';
    const currentPath = window.location.pathname.replace(/^\/(en|zh-Hant)/, '');
    const newUrl = `${baseHref}${langCode}${currentPath}${window.location.search}${window.location.hash}`;
    window.location.href = newUrl;
  }

  getAvailableLanguages(): Language[] {
    return this.languages;
  }
}
