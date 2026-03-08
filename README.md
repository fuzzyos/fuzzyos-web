# FuzzyOS Web

The marketing website for [fuzzy-code](https://github.com/fuzzyos/fuzzy-code) — a minimal terminal coding harness built by FuzzyOS.

## About fuzzy-code

Fuzzy is a minimal terminal coding harness. Adapt fuzzy to your workflows, not the other way around, without having to fork and modify fuzzy internals. Extend it with TypeScript [Extensions](https://github.com/fuzzyos/fuzzy-code#extensions), [Skills](https://github.com/fuzzyos/fuzzy-code#skills), [Prompt Templates](https://github.com/fuzzyos/fuzzy-code#prompt-templates), and [Themes](https://github.com/fuzzyos/fuzzy-code#themes).

```bash
npm install -g @fuzzyos/fuzzy-code
fuzzy
```

## This Website

Built with:

- **Next.js 16** with TypeScript
- **Radix UI Themes** for accessible design
- **WorkOS AuthKit v2.12.2** for authentication
- Docker standalone build with runtime environment variable injection
- Kubernetes-ready with Helm charts

## Getting Started

### Prerequisites

- Node.js 22+
- npm
- A WorkOS account (for authentication features)

### Installation

```bash
cd fuzzyos-web
npm install
```

Copy `.env.local.example` to `.env.local` and update the WorkOS credentials:

```env
WORKOS_API_KEY=your_api_key_here
WORKOS_CLIENT_ID=your_client_id_here
WORKOS_COOKIE_PASSWORD=your_cookie_password_here
NEXT_PUBLIC_WORKOS_REDIRECT_URI=http://localhost:3000/auth/callback
```

### Development

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

### Build

```bash
npm run build
npm start
```

## License

This project is private and proprietary to FuzzyOS.
