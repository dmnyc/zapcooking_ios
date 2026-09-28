//
//  LinkPreviewEntityTests.swift
//  wispTests
//
//  Link preview cards must show special characters from OG metadata as
//  characters, not raw HTML references (e.g. `browser&#039;s` from PHP's
//  zero-padded apostrophe).
//

import Testing
@testable import wisp

struct LinkPreviewEntityTests {

    @Test func decodesZeroPaddedDecimalApostrophe() {
        #expect(HTMLEntityDecoder.decode("browser&#039;s side panel") == "browser's side panel")
    }

    @Test func decodesDecimalAndHexReferences() {
        #expect(HTMLEntityDecoder.decode("it&#39;s &#8212; done&#8230;") == "it's \u{2014} done\u{2026}")
        #expect(HTMLEntityDecoder.decode("don&#x2019;t &#X27;x&#x27;") == "don\u{2019}t 'x'")
    }

    @Test func decodesNamedEntities() {
        #expect(HTMLEntityDecoder.decode("Tom &amp; Jerry &lt;3 &quot;hi&quot; &apos;x&apos;") == "Tom & Jerry <3 \"hi\" 'x'")
        #expect(HTMLEntityDecoder.decode("A &mdash; B&nbsp;C &rsquo;s &copy; Caf&eacute;") == "A \u{2014} B C \u{2019}s \u{00A9} Caf\u{00E9}")
    }

    @Test func decodesDoubleEscapedReferences() {
        #expect(HTMLEntityDecoder.decode("browser&amp;#039;s") == "browser's")
        #expect(HTMLEntityDecoder.decode("A &amp;amp; B") == "A & B")
    }

    @Test func leavesUnknownAndInvalidReferencesAlone() {
        #expect(HTMLEntityDecoder.decode("AT&T and &bogus; and &#0; and &#xD800;") == "AT&T and &bogus; and &#0; and &#xD800;")
        #expect(HTMLEntityDecoder.decode("no entities") == "no entities")
    }

    @Test func ogDescriptionWithRawApostropheIsNotTruncated() {
        let html = #"""
        <meta property="og:title" content="A Classy Nostr Signer &mdash; Sidecar">
        <meta property="og:description" content="A NIP-07 Nostr signer, in your browser's side panel.">
        """#
        let og = LinkPreviewService.shared.parseOgTags(html: html, fallbackUrl: "https://sidecar.top")
        #expect(og?.title == "A Classy Nostr Signer \u{2014} Sidecar")
        #expect(og?.description == "A NIP-07 Nostr signer, in your browser's side panel.")
    }

    @Test func ogDescriptionWithEncodedApostropheDecodes() {
        let html = #"""
        <meta content='It&#039;s "quoted"' property='og:description'>
        <meta property="og:title" content="Title">
        """#
        let og = LinkPreviewService.shared.parseOgTags(html: html, fallbackUrl: "https://example.com")
        #expect(og?.description == "It's \"quoted\"")
    }
}
