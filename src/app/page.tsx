import { Box, Container, Flex, Grid, Heading, Text, Card, Section, Separator, Code } from "@radix-ui/themes";
import {
  RocketIcon,
  LightningBoltIcon,
  CodeIcon,
  MixIcon,
  LayersIcon,
  GlobeIcon,
  GitHubLogoIcon,
  DesktopIcon,
  CheckCircledIcon
} from "@radix-ui/react-icons";

export default function Home() {
  return (
    <>
      {/* Hero Section */}
      <Box style={{ backgroundColor: "var(--accent-2)" }}>
        <Container size="4">
          <Flex direction="column" align="center" py="9" gap="6" style={{ textAlign: "center" }}>
            <Heading size="9" style={{ maxWidth: "900px" }}>
              A Minimal Terminal Coding Harness
            </Heading>
            <Text size="5" color="gray" style={{ maxWidth: "800px" }}>
              Adapt fuzzy to your workflows — not the other way around. Extend it with
              TypeScript Extensions, Skills, Prompt Templates, and Themes. Supports 20+ AI providers.
            </Text>
            <Box>
              <Code size="4" style={{ padding: "12px 24px", display: "block" }}>
                npm install -g @fuzzyos/fuzzy-code
              </Code>
            </Box>
            <Text size="3" color="gray">
              Then run <Code>fuzzy</Code> and start coding.
            </Text>
          </Flex>
        </Container>
      </Box>

      {/* About Section */}
      <Section id="about" size="3">
        <Container size="4">
          <Flex direction="column" gap="6">
            <Heading size="8" align="center">About Fuzzy</Heading>
            <Text size="4" style={{ lineHeight: "1.8", maxWidth: "900px", margin: "0 auto" }}>
              Fuzzy ships with powerful defaults — <Code>read</Code>, <Code>write</Code>, <Code>edit</Code>,
              and <Code>bash</Code> — and skips features like sub-agents and plan mode by design.
              Instead, you can ask fuzzy to build what you want, or install a third-party fuzzy package
              that matches your workflow. Fuzzy runs in four modes: interactive, print/JSON, RPC for
              process integration, and an SDK for embedding in your own apps.
            </Text>
          </Flex>
        </Container>
      </Section>

      <Separator size="4" />

      {/* Features Section */}
      <Section id="features" size="3">
        <Container size="4">
          <Flex direction="column" gap="8">
            <Flex direction="column" gap="4" align="center">
              <Heading size="8" align="center">Features</Heading>
              <Text size="4" color="gray" align="center" style={{ maxWidth: "800px" }}>
                A complete, extensible coding harness — minimal core, infinite possibilities.
              </Text>
            </Flex>

            <Grid columns={{ initial: "1", md: "2" }} gap="6">
              <Card>
                <Flex direction="column" gap="3">
                  <Flex align="center" gap="3">
                    <CodeIcon width="24" height="24" />
                    <Heading size="5">Extensions</Heading>
                  </Flex>
                  <Text size="3" color="gray">
                    TypeScript modules that extend fuzzy with custom tools, commands, keyboard shortcuts,
                    event handlers, and UI components. Build sub-agents, plan mode, custom compaction,
                    permission gates, and more — or install games while you wait (yes, Doom runs).
                  </Text>
                </Flex>
              </Card>

              <Card>
                <Flex direction="column" gap="3">
                  <Flex align="center" gap="3">
                    <MixIcon width="24" height="24" />
                    <Heading size="5">Skills</Heading>
                  </Flex>
                  <Text size="3" color="gray">
                    On-demand capability packages following the Agent Skills standard. Invoke via{" "}
                    <Code>/skill:name</Code> or let the agent load them automatically based on context.
                    Bundle and share them as Fuzzy Packages via npm or git.
                  </Text>
                </Flex>
              </Card>

              <Card>
                <Flex direction="column" gap="3">
                  <Flex align="center" gap="3">
                    <GlobeIcon width="24" height="24" />
                    <Heading size="5">20+ AI Providers</Heading>
                  </Flex>
                  <Text size="3" color="gray">
                    Anthropic Claude, OpenAI, GitHub Copilot, Google Gemini, Azure OpenAI, Amazon Bedrock,
                    Mistral, Groq, xAI, OpenRouter, and many more. Switch models with{" "}
                    <Code>Ctrl+L</Code> or <Code>--model</Code>.
                  </Text>
                </Flex>
              </Card>

              <Card>
                <Flex direction="column" gap="3">
                  <Flex align="center" gap="3">
                    <LayersIcon width="24" height="24" />
                    <Heading size="5">Sessions &amp; Branching</Heading>
                  </Flex>
                  <Text size="3" color="gray">
                    Sessions are stored as JSONL files with a tree structure. Use{" "}
                    <Code>/tree</Code> to navigate and branch from any point in history.
                    Auto-compaction keeps long sessions within context limits.
                  </Text>
                </Flex>
              </Card>

              <Card>
                <Flex direction="column" gap="3">
                  <Flex align="center" gap="3">
                    <DesktopIcon width="24" height="24" />
                    <Heading size="5">Four Execution Modes</Heading>
                  </Flex>
                  <Text size="3" color="gray">
                    Interactive terminal UI, <Code>-p</Code> print/JSON for scripting,
                    <Code>--mode rpc</Code> for process integration, and an SDK for embedding
                    fuzzy directly into your own Node.js applications.
                  </Text>
                </Flex>
              </Card>

              <Card>
                <Flex direction="column" gap="3">
                  <Flex align="center" gap="3">
                    <RocketIcon width="24" height="24" />
                    <Heading size="5">Fuzzy Packages</Heading>
                  </Flex>
                  <Text size="3" color="gray">
                    Bundle extensions, skills, prompts, and themes into shareable packages.
                    Install from npm or git with <Code>fuzzy install</Code>.
                    Find packages on npmjs.com or in the community Discord.
                  </Text>
                </Flex>
              </Card>
            </Grid>
          </Flex>
        </Container>
      </Section>

      <Separator size="4" />

      {/* Philosophy Section */}
      <Section id="philosophy" size="3" style={{ backgroundColor: "var(--gray-2)" }}>
        <Container size="4">
          <Flex direction="column" gap="6">
            <Heading size="8" align="center">Philosophy</Heading>
            <Text size="4" style={{ lineHeight: "1.8", maxWidth: "900px", margin: "0 auto" }}>
              Fuzzy is aggressively extensible so it doesn&apos;t have to dictate your workflow.
              Features that other tools bake in can be built with extensions, skills, or installed
              from third-party fuzzy packages. This keeps the core minimal while letting you shape
              fuzzy to fit how you work.
            </Text>
            <Grid columns={{ initial: "1", md: "2" }} gap="4" style={{ maxWidth: "900px", margin: "0 auto" }}>
              {[
                { label: "No MCP", desc: "Build CLI tools with READMEs (Skills), or add an extension for MCP if you need it." },
                { label: "No sub-agents", desc: "Spawn fuzzy instances via tmux, or build your own with extensions." },
                { label: "No permission popups", desc: "Run in a container, or build your own confirmation flow with extensions." },
                { label: "No plan mode", desc: "Write plans to files, or build it with extensions, or install a package." },
                { label: "No built-in todos", desc: "They confuse models. Use a TODO.md file, or build your own with extensions." },
                { label: "No background bash", desc: "Use tmux. Full observability, direct interaction." },
              ].map(({ label, desc }) => (
                <Flex key={label} gap="3">
                  <CheckCircledIcon width="20" height="20" style={{ color: "var(--accent-9)", flexShrink: 0, marginTop: 2 }} />
                  <Flex direction="column" gap="1">
                    <Text size="3" weight="bold">{label}</Text>
                    <Text size="2" color="gray">{desc}</Text>
                  </Flex>
                </Flex>
              ))}
            </Grid>
          </Flex>
        </Container>
      </Section>

      <Separator size="4" />

      {/* Quick Start Section */}
      <Section id="quickstart" size="3">
        <Container size="4">
          <Flex direction="column" gap="8">
            <Heading size="8" align="center">Quick Start</Heading>
            <Grid columns={{ initial: "1", md: "2" }} gap="6">
              <Card>
                <Flex direction="column" gap="3">
                  <Flex align="center" gap="3">
                    <LightningBoltIcon width="24" height="24" />
                    <Heading size="5">Install</Heading>
                  </Flex>
                  <Code size="2" style={{ whiteSpace: "pre", display: "block", padding: "12px" }}>
{`npm install -g @fuzzyos/fuzzy-code

# With API key
export ANTHROPIC_API_KEY=sk-ant-...
fuzzy

# Or use your subscription
fuzzy
/login`}
                  </Code>
                </Flex>
              </Card>

              <Card>
                <Flex direction="column" gap="3">
                  <Flex align="center" gap="3">
                    <GitHubLogoIcon width="24" height="24" />
                    <Heading size="5">Extend</Heading>
                  </Flex>
                  <Code size="2" style={{ whiteSpace: "pre", display: "block", padding: "12px" }}>
{`# Install a package
fuzzy install npm:@foo/fuzzy-tools

# List installed packages
fuzzy list

# Update packages
fuzzy update`}
                  </Code>
                </Flex>
              </Card>
            </Grid>
          </Flex>
        </Container>
      </Section>

    </>
  );
}
