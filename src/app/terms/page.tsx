import { Box, Container, Heading, Text, Section, Separator } from "@radix-ui/themes";

export const metadata = {
  title: "Terms of Service - FuzzyOS",
  description: "Terms of Service for FuzzyOS",
};

export default function TermsOfService() {
  return (
    <Container size="3" py="9">
      <Heading size="9" mb="6">Terms of Service</Heading>
      <Text size="3" color="gray" mb="8">
        Last Updated: {new Date().toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })}
      </Text>

      <Section size="1">
        <Box mb="6">
          <Text size="3" style={{ lineHeight: "1.8" }}>
            The following terms and conditions (the "Terms") govern your use of the website located at fuzzyos.com and other websites and mobile applications on which FuzzyOS ("we," "us," or "our") posts these Terms (collectively "Sites"). BY USING THE SITE, YOU ACCEPT AND AGREE TO THESE TERMS AS APPLIED TO YOUR USE OF THE SITE.
          </Text>
          <br />
          <Text size="3" style={{ lineHeight: "1.8" }}>
            You should also read our Privacy Policy, which is incorporated by reference into these Terms. If you do not accept and agree to be bound by these Terms, including our Privacy Policy, do not use the Site or the products and services offered on the Site (collectively, "Services"). By accessing the Site, you consent to these Terms in electronic form. To withdraw this consent, you must cease using the Site and, if applicable, terminate your account.
          </Text>
          <br />
          <Text size="3" style={{ lineHeight: "1.8" }}>
            Users under the age of 18 must (a) review these Terms with a parent or legal guardian to ensure the parent or legal guardian acknowledges and agrees to these Terms, and (b) not access the Site and uninstall any application if his or her parent or legal guardian does not agree to these Terms.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">1. Proprietary Rights</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            As between you and us, we own, solely and exclusively, all rights, title and interest in and to the Site, the technology underlying the Services, all the content (including, for example, audio, photographs, illustrations, graphics, other visuals, video and instructional materials and other text), software, code, and data available to you in connection with the Site or Services and all content related to our programs even if the content is not accessed through the Site (collectively, "Company Content"), and the look and feel, design and organization of the Site. Your use of the Site or Services does not grant to you ownership of any Company Content.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">2. Limited License</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            You may access and view the Company Content on your computer or other internet compatible device, and make single copies or prints of the Company Content for your personal, non-commercial use only. To the extent you need to download software or documentation to use the Services, we grant you a limited, non-assignable, non-transferable, revocable license to use such software or documentation solely to utilize the Services. Such license will terminate when you no longer use the Services. For our mobile applications, we grant you a nonexclusive, non-transferable, worldwide, and perpetual license to perform, display, and use the mobile application for your personal, non-commercial use only. The Site and the Services, including any Company Content, are only for your personal, non-commercial use. We reserve the right to change or make corrections to the operation of, or any information available on, the Site at any time and without prior notice.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">3. Trademarks</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            Trademarks, logos, service marks and trade names (collectively, "Trademarks") that are ours or Trademarks of any third party displayed on the Site or on Company Content may not be used unless authorized by the trademark owner. All Trademarks not owned by us that appear on the Site or on or through the Services, if any, are the property of their respective owners. Nothing contained on the Site should be construed as granting, by implication, estoppel, or otherwise, any license or right to use any Trademark displayed on the Site without our written permission or that of the third party rights holder. Your misuse of the Trademarks displayed on the Site is strictly prohibited. For clarity, the foregoing does not prohibit use of Trademarks that constitutes fair use under applicable law.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">4. User Content</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            <strong>(a)</strong> Any ideas, suggestions, survey responses, or testimonials that you submit to us or information you submit or post to our chat rooms, message boards, and/or our blogs ("User Content") will be deemed not to be confidential and may be used by us for any purpose. By submitting or sending User Content to us, you: (i) represent and warrant that the User Content is original to you, that no other party has any rights thereto, and that any "moral rights" in User Content have been waived, and (ii) grant us a royalty-free, unrestricted, worldwide, perpetual, irrevocable, non-exclusive and fully transferable, assignable and sublicensable right and license to display, use, reproduce, incorporate, modify, create derivative works of and distribute the User Content (in whole or part). We are not responsible for maintaining any User Content that you provide to us, and we may delete or destroy any such User Content at any time.
          </Text>
          <br />
          <Text size="3" style={{ lineHeight: "1.8" }}>
            <strong>(b)</strong> By submitting or sending any materials or documents to us through the Site for help from or review by our staff ("Submitted Materials"), you: (i) represent and warrant that the Submitted Materials are original to you, that no other party has any rights thereto, and that any "moral rights" in Submitted Materials have been waived, and (ii) grant us a royalty-free, unrestricted, worldwide, perpetual, irrevocable, non-exclusive and fully transferable, assignable and sublicensable right and license to use the Submitted Materials for quality control, for the professional development of our staff, to improve our products and services, to share with third parties (on a de-identified basis) for research purposes, and to use and share in accordance with our Privacy Policy. We are not responsible for maintaining any Submitted Materials that you provide to us, and we may delete or destroy any such Submitted Materials at any time.
          </Text>
          <br />
          <Text size="3" style={{ lineHeight: "1.8" }}>
            <strong>(c)</strong> You agree that we may record and produce transcripts of all or any part of any live online sessions and meeting sessions (including voice chat communications and videos) for quality control, for the professional development of our staff, to improve our products and services, to share with third parties (on a de-identified basis) for research purposes, and to use and share in accordance with our Privacy Policy. We reserve the right to review such sessions for any purpose. You agree that we own all transcripts and recordings of such sessions, and you hereby irrevocably assign to us all rights in all such transcripts and recordings.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">5. Certain Obligations and Prohibitions</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            <strong>(a)</strong> Any commercial distribution, publishing or exploitation of the Site or any Company Content is strictly prohibited. Except as expressly permitted by these Terms or by law, you may not download, display, copy, reproduce, distribute, modify, perform, transfer, create derivative works of, sell or otherwise exploit any Company Content. If you improperly use the Site, we may aggressively enforce our intellectual property and other rights to the fullest extent of the law, including the seeking of criminal prosecution.
          </Text>
          <br />
          <Text size="3" style={{ lineHeight: "1.8" }}>
            <strong>(b)</strong> We may investigate and/or terminate your account if you misuse the Site or behave in any way that we regard as inappropriate or unlawful. You agree that, while using the Site and the Services, you will not: (i) impersonate any person or entity or misrepresent your affiliation with any other person or entity; (ii) insert your own or a third party's advertising, branding or other promotional content into any of the Company Content or Services; or (iii) gain or attempt to gain unauthorized access to other computer systems through the Site.
          </Text>
          <br />
          <Text size="3" style={{ lineHeight: "1.8" }}>
            <strong>(c)</strong> You agree to not: (i) engage in spidering, "screen scraping," "database scraping," harvesting of e-mail addresses, wireless addresses or other contact or personal information, or any other automatic means of accessing, logging-in or registering on the Site or for any Services or features offered on or through the Site, or obtaining lists of users or obtaining or accessing other information or features on, from or through the Site or the Services including but not limited to any information residing on any server or database connected to the Site or any Services; (ii) use the Site or the Services in any manner with the intent to interrupt, damage, disable, overburden, or impair the Site or the Services, including but not limited to sending mass unsolicited messages or "flooding" servers with requests; or (iii) use the Site or the Services in violation of any applicable law or the legal rights of any third party.
          </Text>
          <br />
          <Text size="3" style={{ lineHeight: "1.8" }}>
            <strong>(d)</strong> You agree that you will not attempt (or encourage or support anyone else's attempt) to circumvent, reverse engineer, decrypt, or otherwise alter or interfere with the Site or the Services, or any content thereof, or make unauthorized use thereof.
          </Text>
          <br />
          <Text size="3" style={{ lineHeight: "1.8" }}>
            <strong>(e)</strong> You agree that you will not upload, post, transmit, distribute or otherwise publish through the Site, the Services, or any feature made available on or through the Site, any materials or code which (i) restrict or inhibit any other user from using and enjoying the Site or the Services, (ii) are fraudulent, unlawful, threatening, abusive, harassing, defamatory, obscene, vulgar, offensive, profane, sexually explicit or indecent, (iii) violate any local, state, national or international law, (iv) violate, plagiarize or infringe the intellectual property, privacy, publicity, or other rights of third parties, (v) contain a virus, spyware, or other harmful component, (vi) contain embedded links, advertising, chain letters or pyramid schemes of any kind, or (vii) constitute or contain false or misleading indications of origin, endorsement or statements of fact.
          </Text>
          <br />
          <Text size="3" style={{ lineHeight: "1.8" }}>
            <strong>(f)</strong> If you use, or assist another person in using, our services in any unauthorized way, you agree that you will pay us an additional $50 per hour for any time we spend to investigate and correct such use, plus any third party costs of investigation we incur (with a minimum $250 charge). You agree that we may charge any credit card number provided for your account for such amounts. You further agree that you will not dispute such a charge and that we retain the right to collect any additional actual costs.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">6. Right to Monitor and Editorial Control</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            We reserve the right, but do not have an obligation, to (a) monitor and/or review all materials posted to the Site or through the Services or Site's features or (b) refuse to post or to remove any information or materials, in whole or in part, that in our sole discretion are objectionable, violate these Terms, or violate applicable law. We may also impose limits on certain features of the forums or restrict your access to part or all of the forums without notice or penalty if we believe you are in breach of the guidelines set forth in this paragraph, our Terms or applicable law, or for any other reason without notice of liability.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">7. Private or Sensitive Information on Public Forums</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            We may, from time to time, make messaging services, chat services, bulletin boards, message boards, blogs, other forums and other such services available on or through the Site. It is important to remember that comments submitted to a forum may be recorded and stored in multiple places, both on our Site and elsewhere on the Internet, which are likely to be accessible for a long time and you have no control over who will read them now or in the future. It is therefore important that you are careful and selective about the personal information that you disclose about yourself and others, and in particular, you should not disclose sensitive, proprietary or confidential information in your comments to our public forums.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">8. Copyrights and Copyright Agent</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            We respect the intellectual property of others, and we ask our users to do the same. If you believe that your work has been copied and posted on the Site in a way that constitutes copyright infringement or your intellectual property rights have been otherwise violated, please provide our Copyright Agent a notice with the following information:
          </Text>
          <br />
          <Text size="3" style={{ lineHeight: "1.8" }}>
            • An electronic or physical signature of the person authorized to act on behalf of the owner of the copyright or other intellectual property interest;<br />
            • A description of the copyrighted work or other intellectual property that you claim has been infringed;<br />
            • A description of where the material that you claim is infringing is located on the Site;<br />
            • Your address, telephone number and email address;<br />
            • A written statement by you that you have a good faith belief that the disputed use is not authorized by the copyright owner, its agent, or the law; and<br />
            • A statement by you, made under penalty of perjury, that the above information in your notice is accurate and that you are the copyright or other intellectual property owner or authorized to act on the owner's behalf.
          </Text>
          <br />
          <Text size="3" style={{ lineHeight: "1.8" }}>
            Notice of claims of copyright or other intellectual property infringement can be provided to our Copyright Agent at: <strong>copyright@fuzzyos.com</strong>
          </Text>
          <br />
          <Text size="3" style={{ lineHeight: "1.8" }}>
            We may terminate the accounts of any infringers.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">9. Links</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            <strong>(a)</strong> You may be able to link from the Site to third party websites and third party websites may link to the Site. You acknowledge and agree that we have no responsibility for the content, products, services, advertising or other materials which may be provided by or through third party websites. Links to third party websites do not constitute an endorsement or sponsorship by us of such websites or the information, content, products, services, advertising, code or other materials presented on or through such websites. Any reliance on the contents of a third party website is done at your own risk and you assume all responsibilities and consequences resulting from such reliance.
          </Text>
          <br />
          <Text size="3" style={{ lineHeight: "1.8" }}>
            <strong>(b)</strong> You agree that if you include a link from any other website to the Site, such link will open in a new browser window and will link to the full version of an HTML formatted page of the Site. You are not permitted to link directly to any image hosted on the Site or the Services, such as using an "in-line" linking method to cause the image hosted by us to be displayed on another website. You agree not to download or use images hosted on the Site on another website, for any purpose. You agree not to link from any other website to the Site in any manner such that the Site, or any page of the Site, is "framed," surrounded or obfuscated by any third party content, materials or branding.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">10. Indemnification</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            You agree to defend, indemnify and hold us and our directors, officers, employees and agents harmless from any and all claims, liabilities, costs and expenses, including reasonable attorneys' fees, arising in any way from any content or other material you place on the Site or submit to us, or your breach or violation of the law or of these Terms. We reserve the right, at our own expense, to assume the exclusive defense and control of any matter otherwise subject to indemnification by you, and in such case, you agree to cooperate with our defense of such claim.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">11. Products and Services</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            <strong>(a)</strong> You are solely responsible for all computer hardware and other equipment and all fees for services (such as internet service and wireless services) required for access and use of our on-line Services.
          </Text>
          <br />
          <Text size="3" style={{ lineHeight: "1.8" }}>
            <strong>(b)</strong> To use the Services, you will need to register on the Site, pay any applicable fees, and create an account, username and password. You agree to provide accurate information about yourself. If we believe that such information is inaccurate, we reserve the right to suspend or terminate your account and refuse any and all use of the Services. You are responsible for maintaining the confidentiality of your account information and for all activities and liabilities associated with or occurring under your account. You must notify us immediately of any unauthorized use of your account or username. You may not transfer your account (including your username or password) to another person and you may not use anyone else's account at any time without the permission of the account holder. In cases where you have authorized or registered another individual, including a minor, to use your account, you are fully responsible for (i) the online conduct of such user; (ii) controlling the user's access to and use of the Services; and (iii) the consequences of any misuse.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">12. Disclaimer of Warranties</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            <strong>(a)</strong> THE SITE, THE SERVICES, AND COMPANY CONTENT ARE PROVIDED "AS IS," "AS AVAILABLE", WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO ANY WARRANTY REGARDING UPTIME OR UNINTERRUPTED ACCESS, AVAILABILITY, ACCURACY, OR USEFULNESS, AND ANY WARRANTIES OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. WE HEREBY DISCLAIM ANY AND ALL SUCH WARRANTIES, EXPRESS AND IMPLIED. WE ALSO ASSUME NO RESPONSIBILITY, AND WILL NOT BE LIABLE FOR, ANY DAMAGES TO, OR VIRUSES THAT MAY INFECT, YOUR COMPUTER EQUIPMENT, MOBILE DEVICE, OR OTHER PROPERTY ON ACCOUNT OF YOUR ACCESS TO OR USE OF THE SITE, THE SERVICES, OR YOUR DOWNLOADING OF ANY COMPANY CONTENT FROM THE SITE. IF YOU ARE DISSATISFIED WITH THE SITE, YOUR SOLE REMEDY IS TO DISCONTINUE USING THE SITE.
          </Text>
          <br />
          <Text size="3" style={{ lineHeight: "1.8" }}>
            <strong>(b)</strong> From time to time, we may make third party opinions, advice, statements, offers, or other third party information or content available on the Site ("Third Party Content"). All Third Party Content is the responsibility of the respective authors thereof and should not necessarily be relied upon. WE DO NOT: (I) GUARANTEE THE ACCURACY, COMPLETENESS, OR USEFULNESS OF ANY THIRD PARTY CONTENT ON THE SITE OR (II) ADOPT, ENDORSE OR ACCEPT RESPONSIBILITY FOR THE ACCURACY OR RELIABILITY OF ANY OPINION, ADVICE, OR STATEMENT MADE BY ANY THIRD PARTY THAT APPEARS ON THE SITE. UNDER NO CIRCUMSTANCES WILL WE BE RESPONSIBLE OR LIABLE FOR ANY LOSS OR DAMAGE RESULTING FROM YOUR RELIANCE ON INFORMATION OR OTHER CONTENT POSTED ON OR AVAILABLE FROM THE SITE OR THE SERVICES.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">13. Limitation of Liability</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            <strong>(a)</strong> IN NO EVENT, INCLUDING BUT NOT LIMITED TO NEGLIGENCE, WILL WE OR ANY OF OUR DIRECTORS, OFFICERS, EMPLOYEES, AGENTS OR CONTENT OR SERVICE PROVIDERS (COLLECTIVELY, THE "PROTECTED ENTITIES") BE LIABLE FOR ANY INDIRECT, SPECIAL, INCIDENTAL, CONSEQUENTIAL, EXEMPLARY OR PUNITIVE DAMAGES ARISING FROM, OR DIRECTLY OR INDIRECTLY RELATED TO, THE USE OF, OR THE INABILITY TO USE, THE SITE, THE SERVICES, OR COMPANY CONTENT, YOUR PROVISION OF INFORMATION VIA THE SITE, LOST BUSINESS OR LOST SALES, EVEN IF SUCH PROTECTED ENTITY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. SOME JURISDICTIONS DO NOT ALLOW THE LIMITATION OR EXCLUSION OF LIABILITY FOR INCIDENTAL OR CONSEQUENTIAL DAMAGES SO SOME OF THE ABOVE LIMITATIONS MAY NOT APPLY TO CERTAIN USERS TO THE EXTENT REQUIRED BY APPLICABLE LAW.
          </Text>
          <br />
          <Text size="3" style={{ lineHeight: "1.8" }}>
            <strong>(b)</strong> IN NO EVENT WILL THE PROTECTED ENTITIES BE LIABLE FOR OR IN CONNECTION WITH ANY CONTENT POSTED, TRANSMITTED, EXCHANGED OR RECEIVED BY OR ON BEHALF OF ANY USER OR OTHER PERSON ON OR THROUGH THE SITE OR THE SERVICES. IN NO EVENT WILL THE TOTAL AGGREGATE LIABILITY OF THE PROTECTED ENTITIES TO YOU FOR ALL DAMAGES, LOSSES, AND CAUSES OF ACTION (WHETHER IN CONTRACT OR TORT OR OTHERWISE, INCLUDING, BUT NOT LIMITED TO, NEGLIGENCE) ARISING FROM THESE TERMS OR YOUR USE OF THE SITE, THE SERVICES, OR COMPANY CONTENT EXCEED, IN THE AGGREGATE, THE AMOUNT, IF ANY, PAID BY YOU TO US FOR YOUR USE OF THE SITE OR THE SERVICES IN THE 12 MONTH PERIOD PRECEDING YOUR CLAIM.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">14. Applicable Laws and Arbitration</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            We control and operate the Site and Services from our offices in the United States of America. We do not represent that materials on the Site or Services are appropriate for use in other locations. Persons who choose to access the Site or Services from other locations do so on their own initiative, and are responsible for compliance with local laws, if and to the extent local laws are applicable. All parties to these Terms waive their respective rights to a trial by jury. The exclusive means of resolving any dispute or claim arising out of or relating to these Terms (including any alleged breach thereof) or the Site or Services will be BINDING ARBITRATION administered by the American Arbitration Association. The one exception to the exclusivity of arbitration is that you have the right to bring an individual claim against us in a small-claims court of competent jurisdiction. But whether you choose arbitration or small-claims court, you may not under any circumstances commence or maintain against us any class action, class arbitration, or other representative action or proceeding.
          </Text>
          <br />
          <Text size="3" style={{ lineHeight: "1.8" }}>
            <strong>(a)</strong> By using the Site or Services, you agree to the above arbitration agreement. In doing so, YOU GIVE UP YOUR RIGHT TO GO TO COURT to assert or defend any claims between you and us (except for matters that may be taken to small-claims court). YOU ALSO GIVE UP YOUR RIGHT TO PARTICIPATE IN A CLASS ACTION OR OTHER CLASS PROCEEDING. Your rights will be determined by a NEUTRAL ARBITRATOR, NOT A JUDGE OR JURY. You are entitled to a fair hearing before the arbitrator. The arbitrator can grant any relief that a court can, but you should note that arbitration proceedings are usually simpler and more streamlined than trials and other judicial proceedings. Decisions by the arbitrator are enforceable in court and may be overturned by a court only for very limited reasons.
          </Text>
          <br />
          <Text size="3" style={{ lineHeight: "1.8" }}>
            <strong>(b)</strong> Any proceeding to enforce this arbitration agreement, including any proceeding to confirm, modify, or vacate an arbitration award, may be commenced in any court of competent jurisdiction. In the event that this arbitration agreement is for any reason held to be unenforceable, any litigation against us (except for small-claims court actions) may be commenced only in the federal or state courts located in the state in which our principal office is located. You hereby irrevocably consent to the jurisdiction of those courts for such purposes.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">15. Termination</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            We may terminate, change, suspend or discontinue any aspect of the Site or the Services at any time. We may restrict, suspend or terminate your access to the Site or the Services if we believe you are in breach of these Terms or applicable law, you are a repeat infringer of intellectual property rights, or for any other reason without notice or liability.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">16. Changes to Terms of Service</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            We reserve the right, at our sole discretion, to modify any portion of these Terms at any time. Changes in these Terms will be effective when posted. Your continued use of the Site and/or the Services after any changes to these Terms are posted will be considered acceptance of those changes.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">17. Communication</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            If you provide us your email address, you agree and consent to receive email messages from us. These emails may be transactional or relationship communications relating to the products or services we offer, such as administrative notices and service announcements or changes, or emails containing commercial offers, promotions or special offers from us. You also may sign up, and therefore agree, to receive SMS or text messages on your mobile phone.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">18. Miscellaneous</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            These Terms comprise the entire agreement between you and us concerning the subject matter of these Terms. Our failure to exercise or enforce any right or provision of these Terms will not constitute a waiver of such right or provision. We may assign these Terms to any person or entity without your consent. You may not assign these Terms without our prior written consent. If any provision of these Terms is found by a court of competent jurisdiction to be invalid, the parties nevertheless agree that the court should endeavor to give effect to the parties' intentions as reflected in the provision, and the other provisions of these Terms remain in full force and effect.
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Heading size="6" mb="3">19. Contact Information</Heading>
          <Text size="3" style={{ lineHeight: "1.8" }}>
            If you have questions about these Terms of Service, please contact us at:<br /><br />
            <strong>FuzzyOS</strong><br />
            Email: contact@fuzzyos.com
          </Text>
        </Box>

        <Separator size="4" my="6" />

        <Box mb="6">
          <Text size="3" style={{ lineHeight: "1.8", fontStyle: "italic" }}>
            By using our services, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service.
          </Text>
        </Box>
      </Section>
    </Container>
  );
}
