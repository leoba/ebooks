<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei" version="2.0">
    
    <!-- At present this script can only be used to create HTML files that point to local images -->

    <xsl:template match="/">
        
        

        <xsl:variable name="mstitle" select="substring(//tei:titleStmt/tei:title,16)"/>
        <xsl:variable name="summary" select="//tei:summary"/>
        <xsl:variable name="recordURL" select="//tei:altIdentifier[@type='resource']/tei:idno"/>
        <xsl:variable name="callNo" select="translate(//tei:idno[@type='call-number'],' ','')"/>
        <xsl:variable name="teiFileNameURI" select="document-uri(/)"/>
        <xsl:variable name="teiFileName" select="tokenize($teiFileNameURI,'/')[position() = last()]"/>
        <xsl:variable name="msID" select="replace($teiFileName,'_TEI.xml','')"/>
        <xsl:variable name="baseURL">http://openn.library.upenn.edu/Data/</xsl:variable>
        <xsl:variable name="repositoryID">
            <xsl:choose>
                <xsl:when test="starts-with($msID,'m')">0002</xsl:when>
                <xsl:when test="starts-with($msID,'l')">0001</xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:result-document href="input/{$callNo}.html">
            
            <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                <title>Facsimile of <xsl:value-of select="$mstitle"/></title>
                <style type="text/css">
                    hr {page-break-after:always;}
                </style>
            </head>
            <body>
                <h3>Facsimile of <xsl:value-of select="$mstitle"/></h3>
                <p>
                    <xsl:value-of select="$summary"/>
                </p>
                <hr/>
                <p>The manuscript contained in this facsimile is the <xsl:choose>
                    <xsl:when test="$recordURL != ''"><a href="{$recordURL}"><xsl:value-of select="$mstitle"/></a></xsl:when>
                    <xsl:otherwise><xsl:value-of select="$mstitle"/></xsl:otherwise>
                </xsl:choose>.</p>
                <p>To read descriptions of illustrations, figures, or initials on a page, click on the page image.</p>
                <p>Digital images are courtesy of <a href="http://openn.library.upenn.edu/"
                        >OPenn, Making Primary Sources Available to Everyone</a>, hosted by the
                    University of Pennsylvania Libraries.</p>
                <hr/>
                <xsl:choose>
                    <xsl:when test="string-length($summary) > 500"/>
                    <xsl:when test="string-length($summary) > 1000"><p>[This page left purposefully blank.]</p></xsl:when>
                    <xsl:otherwise><p>[This page left purposefully blank.]</p></xsl:otherwise>
                </xsl:choose>
                
                <hr/>
                
                <xsl:for-each select="//tei:surface">
                    <xsl:variable name="folNo" select="replace(replace(@n,' ',''),',','')"/>
                    <xsl:variable name="id"><xsl:number format="001"/>-<xsl:value-of select="$folNo"/></xsl:variable>
                    <!--<xsl:if test="matches($folNo, '\d+r') or matches($folNo, '\d+v') or matches($folNo, '^\d+') or matches($folNo, '^\d+')">-->
                        <xsl:for-each select="tei:graphic[starts-with(@url,'web')]">
                            <xsl:variable name="img" select="substring(@url,5)"/>
                            <xsl:variable name="full_path_to_img" select="concat($baseURL,$repositoryID,'/',$msID,'/data/web/',$img)"/>
                            
                            <!-- When you are using this to create an ebook you will need to have the images locally. In that case use this bit of code -->
                            
                            <p>
                                <a href="#{$id}" name="img-{$id}" title="Folio {$folNo}"><img src="{$img}" alt="{$folNo}"/></a>
                                
                            </p>
                            
                            <!-- When you will be using this for other reasons - and you don't have the images locally - comment the code above and uncomment this -->
                            
                                <p>
                                    <a href="#{$id}"
                                        name="img-{$id}"
                                        title="Folio {$folNo}">
                                        <img src="{$full_path_to_img}" alt="{$folNo}"/>
                                    </a>
                                </p>
                        </xsl:for-each>
                    <!--</xsl:if>-->
                </xsl:for-each>
                
                <xsl:for-each select="//tei:surface">
                    <xsl:variable name="folNo" select="replace(replace(@n,' ',''),',','')"/>
                    <xsl:variable name="id"><xsl:number format="001"/>-<xsl:value-of select="$folNo"/></xsl:variable>
                    <!--<xsl:if test="matches($folNo, '\d+r') or matches($folNo, '\d+v') or matches($folNo, '^\d+') or matches($folNo, '^\d+')">-->
                    <!-- This originally tested for foliation or pagination but I don't think that's right so I'm removing the if test -->
                     <xsl:for-each select="tei:graphic[starts-with(@url,'web')]">
                            <xsl:variable name="img" select="substring(@url,5)"/>
                            <xsl:variable name="full_path_to_img" select="concat($baseURL,$repositoryID,'/',$msID,'/data/web/',$img)"/>
                         
                            
                                <p><a href="#img-{$id}" name="{$id}">Back to image</a></p>
                            
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
                         <p><a href="{$full_path_to_img}">If you are connected to the Internet, view a high-resolution version of this image in a browser.</a></p>
                        </xsl:for-each>
                        
                            <hr/>
                        
                    
                </xsl:for-each>
            </body>
        </html>
        </xsl:result-document>
    </xsl:template>
    
</xsl:stylesheet>
