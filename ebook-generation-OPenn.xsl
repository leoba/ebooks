<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei" version="2.0">

    <xsl:template match="/">
        
        <xsl:variable name="orientationURL"></xsl:variable>

        <xsl:variable name="title" select="substring(//tei:titleStmt/tei:title,16)"/>
        <xsl:variable name="summary" select="//tei:summary"/>
        <xsl:variable name="recordURL" select="//tei:altIdentifier/tei:idno"/>
        

        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <title>Facsimile of <xsl:value-of select="$title"/></title>
                <style type="text/css">
                    hr {page-break-after:always;}
                </style>
            </head>
            <body>
                <h3>Facsimile of <xsl:value-of select="$title"/></h3>
                <p>
                    <xsl:value-of select="$summary"/>
                </p>
                <hr/>
                <p>The manuscript contained in this facsimile is the <a href="{$recordURL}"
                            ><xsl:value-of select="$title"/></a>. <xsl:if test="$orientationURL"
                        >There is a <a href="{$orientationURL}">video orientation</a> available for
                        this manuscript.</xsl:if></p>
                <p>To read descriptions of illustrations, figures, or initials on a page, click on the folio image.</p>
                <p>Digital images are courtesy of <a href="http://openn.library.upenn.edu/"
                        >OPenn, Making Primary Sources Available to Everyone</a>, hosted by the
                    University of Pennsylvania Libraries.</p>
                <hr/>
                <p>[This page left purposefully blank.]</p>
                <hr/>
                <xsl:for-each select="//tei:surface">
                    <xsl:variable name="folNo" select="@n"/>
                    <xsl:if test="matches($folNo, '\d+r') or matches($folNo, '\d+v')">
                        <xsl:for-each select="tei:graphic[starts-with(@url,'web')]">
                            <xsl:variable name="img" select="substring(@url,5)"/>
                            <p>
                                <a href="#{$folNo}" name="img-{$folNo}" title="Folio {$folNo}"><img src="{$img}" alt="{$folNo}"/></a>
                                <!--<center>Folio <xsl:value-of select="$folNo"/></center>-->
                            </p>
                        </xsl:for-each>
                    </xsl:if>
                </xsl:for-each>
                <xsl:for-each select="//tei:surface">
                    <xsl:variable name="folNo" select="@n"/>
                    <xsl:if test="matches($folNo, '\d+r') or matches($folNo, '\d+v')">
                        <xsl:for-each select="tei:graphic[starts-with(@url,'web')]">
                            <xsl:variable name="img" select="substring(@url,5)"/>
                            
                                <p><a href="#img-{$folNo}" name="{$folNo}">Back to image</a></p>
                            
                            <xsl:if test="not(//tei:msItem[@n=$folNo]) and not(//tei:decoNote[@n=$folNo])">
                                <p>There are no illustrations, figures, or initials on this page.</p>
                            </xsl:if>
                            <xsl:for-each select="//tei:msItem[@n=$folNo]">
                                <p>
                                    <xsl:value-of select="tei:title"/>
                                </p>
                            </xsl:for-each>
                            <xsl:for-each select="//tei:decoNote[@n=$folNo]">
                                <p>
                                    <xsl:value-of select="."/>
                                </p>
                            </xsl:for-each>
                        </xsl:for-each>
                        
                            <hr/>
                        
                    </xsl:if>
                </xsl:for-each>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
