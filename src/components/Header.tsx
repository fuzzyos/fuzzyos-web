"use client";

import { Box, Container, Flex, Text, Button, DropdownMenu, Avatar, Skeleton } from "@radix-ui/themes";
import { PersonIcon, ExitIcon } from "@radix-ui/react-icons";
import Link from "next/link";
import Image from "next/image";
import { useAuth } from "@workos-inc/authkit-nextjs/components";
import { signOut } from "@workos-inc/authkit-nextjs";

export default function Header() {
  const { user, loading } = useAuth();

  return (
    <Box
      style={{
        borderBottom: "1px solid var(--gray-a5)",
        backgroundColor: "var(--color-background)",
      }}
    >
      <Container size="4">
        <Flex
          justify="between"
          align="center"
          py="4"
          gap="4"
        >
          {/* Logo */}
          <Link href="/">
            <Image
              src="/images/logo.svg"
              alt="FuzzyOS"
              width={180}
              height={50}
              priority
              style={{ height: 'auto' }}
            />
          </Link>

          {/* Navigation */}
          <Flex gap="6" align="center">
            <Link href="/#about">
              <Text size="3" weight="medium" style={{ cursor: "pointer" }}>
                About
              </Text>
            </Link>
            <Link href="/#features">
              <Text size="3" weight="medium" style={{ cursor: "pointer" }}>
                Features
              </Text>
            </Link>
            <Link href="/#philosophy">
              <Text size="3" weight="medium" style={{ cursor: "pointer" }}>
                Philosophy
              </Text>
            </Link>
            <Link href="/#quickstart">
              <Text size="3" weight="medium" style={{ cursor: "pointer" }}>
                Quick Start
              </Text>
            </Link>

            {/* Auth Section */}
            {loading ? (
              <Skeleton>
                <Button size="2" variant="soft">
                  <PersonIcon />
                  Loading...
                </Button>
              </Skeleton>
            ) : user ? (
              <DropdownMenu.Root>
                <DropdownMenu.Trigger>
                  <Button size="2" variant="soft">
                    <Avatar
                      size="1"
                      fallback={user.firstName?.[0] || user.email[0].toUpperCase()}
                      radius="full"
                    />
                    {user.firstName || user.email}
                  </Button>
                </DropdownMenu.Trigger>
                <DropdownMenu.Content>
                  <DropdownMenu.Item disabled>
                    <Text size="2" color="gray">{user.email}</Text>
                  </DropdownMenu.Item>
                  <DropdownMenu.Separator />
                  <DropdownMenu.Item
                    color="red"
                    onSelect={async () => {
                      try {
                        await signOut();
                        // The signOut function should handle the redirect automatically
                      } catch (error) {
                        console.error('Sign out error:', error);
                      }
                    }}
                  >
                    <ExitIcon />
                    Sign Out
                  </DropdownMenu.Item>
                </DropdownMenu.Content>
              </DropdownMenu.Root>
            ) : (
              <Link href="/auth/signin">
                <Button size="2" variant="soft">
                  <PersonIcon />
                  Sign In
                </Button>
              </Link>
            )}
          </Flex>
        </Flex>
      </Container>
    </Box>
  );
}
