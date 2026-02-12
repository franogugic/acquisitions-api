import arcjet, { shield, detectBot, slidingWindow } from '@arcjet/node';

const isProd = process.env.NODE_ENV === 'production';

const aj = arcjet({
  key: process.env.ARCJET_KEY,
  rules: [
    shield({ mode: isProd ? 'LIVE' : 'DRY_RUN' }),

    detectBot({ mode: isProd ? 'LIVE' : 'DRY_RUN', allow: ['CATEGORY:SEARCH_ENGINE', 'CATEGORY:PREVIEW'] }),

    slidingWindow({ mode: isProd ? 'LIVE' : 'DRY_RUN', interval: '2s', max: 5 }),
  ],
});

export default aj;
