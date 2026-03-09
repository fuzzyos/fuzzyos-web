import { Box, Container, Flex, Grid, Text, Link as RadixLink, Separator } from "@radix-ui/themes";
import { LinkedInLogoIcon, InstagramLogoIcon, TwitterLogoIcon, EnvelopeClosedIcon } from "@radix-ui/react-icons";
import Link from "next/link";

export default function Footer() {
  return (
    <Box
      style={{
        backgroundColor: "var(--gray-2)",
        borderTop: "1px solid var(--gray-a5)",
      }}
    >
      <Container size="4">
        <Box py="8">
          <Grid columns={{ initial: "1", md: "3" }} gap="8">
            {/* Company Info */}
            <Flex direction="column" gap="4">
              <Flex direction="column" gap="2">
                <Text size="5" weight="bold" style={{ color: "#0044FF" }}>
                  FuzzyOS
                </Text>
                <Text size="3" weight="medium" style={{ color: "#8b8b8b" }}>
                  Minimal Terminal Coding Harness
                </Text>
              </Flex>
              <Text size="2" color="gray">
                Adapt fuzzy to your workflow.
              </Text>
              <Text size="2" color="gray">
                Extensible by design. Minimal by default.
              </Text>
            </Flex>

            {/* Quick Links */}
            <Flex direction="column" gap="3">
              <Text size="3" weight="bold">Quick Links</Text>
              <Flex direction="column" gap="2">
                <Link href="/#about">
                  <Text size="2" style={{ cursor: "pointer" }} color="gray">About</Text>
                </Link>
                <Link href="/#features">
                  <Text size="2" style={{ cursor: "pointer" }} color="gray">Features</Text>
                </Link>
                <Link href="/#philosophy">
                  <Text size="2" style={{ cursor: "pointer" }} color="gray">Philosophy</Text>
                </Link>
                <Link href="/#quickstart">
                  <Text size="2" style={{ cursor: "pointer" }} color="gray">Quick Start</Text>
                </Link>
                <Link href="/#contact">
                  <Text size="2" style={{ cursor: "pointer" }} color="gray">Contact</Text>
                </Link>
              </Flex>
            </Flex>

            {/* Contact & Social */}
            <Flex direction="column" gap="3">
              <Text size="3" weight="bold">Connect With Us</Text>
              <Flex direction="column" gap="2">
                <Flex align="center" gap="2">
                  <EnvelopeClosedIcon />
                  <Text size="2" color="gray">contact@fuzzyos.com</Text>
                </Flex>
              </Flex>
              <Flex display="none" gap="4" mt="3">
                <RadixLink href="https://linkedin.com" target="_blank" style={{ cursor: "pointer" }}>
                  <LinkedInLogoIcon width="24" height="24" />
                </RadixLink>
                <RadixLink href="https://instagram.com" target="_blank" style={{ cursor: "pointer" }}>
                  <InstagramLogoIcon width="24" height="24" />
                </RadixLink>
                <RadixLink href="https://twitter.com" target="_blank" style={{ cursor: "pointer" }}>
                  <TwitterLogoIcon width="24" height="24" />
                </RadixLink>
              </Flex>
            </Flex>
          </Grid>

          <Separator size="4" my="6" />

          <Flex justify="between" align="center" gap="4" wrap="wrap">
            <Text size="2" color="gray">
              © 2025 FuzzyOS. All rights reserved.
            </Text>
            <Flex gap="4">
              <Link href="/privacy">
                <Text size="2" color="gray" style={{ cursor: "pointer" }}>Privacy Policy</Text>
              </Link>
              <Link href="/terms">
                <Text size="2" color="gray" style={{ cursor: "pointer" }}>Terms of Service</Text>
              </Link>
            </Flex>
          </Flex>
        </Box>
      </Container>
    </Box>
  );
}
