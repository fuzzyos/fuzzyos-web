import { Box, Container, Heading, Text, Section, Separator } from "@radix-ui/themes";

export const metadata = {
  title: "Privacy Policy - FuzzyOS",
  description: "Privacy Policy for FuzzyOS (fuzzy-code)",
};

export default function PrivacyPolicy() {
  return (
    <Container size="3" py="9">
      <Heading size="9" mb="6">Privacy Policy</Heading>
      <Text size="3" color="gray" mb="8">
        Last Updated: {new Date().toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })}
      </Text>

      <Section size="1">
        <Box mb="6">
          <Heading size="6" mb="3">1. Introduction</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            FuzzyOS ("we," "our," or "us") respects your privacy and is committed to protecting your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our software products and website.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">2. Information We Collect</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }} mb="3">
            We may collect the following types of information:
          </Text>

          <Box mb="4">
            <Heading size="4" mb="2">Account Information</Heading>
            <Text size="3" style={{ lineHeight: "1.8" }}>
              • Name and email address<br />
              • Payment and billing information<br />
              • Account preferences and settings
            </Text>
          </Box>

          <Box mb="4">
            <Heading size="4" mb="2">Usage Information</Heading>
            <Text size="3" style={{ lineHeight: "1.8" }}>
              • Session data and command history (stored locally by default)<br />
              • Extension and package installations<br />
              • Crash reports and error logs (if opted in)
            </Text>
          </Box>

          <Box mb="4">
            <Heading size="4" mb="2">Technical Information</Heading>
            <Text size="3" style={{ lineHeight: "1.8" }}>
              • IP address and browser type<br />
              • Device information<br />
              • Cookies and usage data<br />
              • Log files and analytics data
            </Text>
          </Box>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">3. How We Use Your Information</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            We use the information we collect to:<br /><br />
            • Provide and improve our software products and services<br />
            • Process payments and manage subscriptions<br />
            • Communicate with users about updates and support<br />
            • Maintain and improve our services<br />
            • Comply with legal obligations<br />
            • Prevent fraud and enhance security<br />
            • Send administrative information and updates<br />
            • Analyze usage patterns and improve product quality
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">4. How We Share Your Information</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            We may share your information with:<br /><br />
            • Service providers and vendors (payment processing, hosting, analytics)<br />
            • Legal and regulatory authorities when required by law<br />
            • Professional advisors (lawyers, accountants)<br />
            • Third parties in connection with a business transfer or acquisition<br /><br />
            We do not sell your personal information to third parties.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">5. Data Security</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. These measures include encryption, secure servers, access controls, and regular security assessments. However, no method of transmission over the internet is 100% secure, and we cannot guarantee absolute security.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">6. Data Retention</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            We retain your personal information for as long as necessary to fulfill the purposes outlined in this Privacy Policy, unless a longer retention period is required or permitted by law. When we no longer need your information, we will securely delete or anonymize it.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">7. Your Rights and Choices</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            Depending on your location, you may have the following rights:<br /><br />
            • Access to your personal information<br />
            • Correction of inaccurate information<br />
            • Deletion of your information<br />
            • Restriction of processing<br />
            • Data portability<br />
            • Objection to processing<br />
            • Withdrawal of consent<br /><br />
            To exercise these rights, please contact us using the information provided below.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">8. Cookies and Tracking Technologies</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            We use cookies and similar tracking technologies to enhance your experience, analyze usage patterns, and improve our services. You can control cookies through your browser settings, but disabling cookies may affect certain features of our website.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">9. Third-Party Links</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            Our website may contain links to third-party websites. We are not responsible for the privacy practices of these external sites. We encourage you to review their privacy policies before providing any personal information.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">10. Children's Privacy</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            Our services are not intended for individuals under the age of 18. We do not knowingly collect personal information from children. If we learn that we have collected information from a child, we will delete it immediately.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">11. Changes to This Privacy Policy</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            We may update this Privacy Policy from time to time. We will notify you of any material changes by posting the updated policy on our website and updating the "Last Updated" date. Your continued use of our services after such changes constitutes acceptance of the updated policy.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">12. Contact Us</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            If you have questions about this Privacy Policy or wish to exercise your privacy rights, please contact us at:<br /><br />
            <strong>FuzzyOS</strong><br />
            Email: contact@fuzzyos.com
          </Text>
        </Box>
      </Section>
    </Container>
  );
}
