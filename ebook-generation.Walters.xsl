<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei" version="2.0">

    <xsl:template match="/">

        <xsl:variable name="orientationURL"/>

        <xsl:variable name="title" select="//tei:titleStmt/tei:title[@type='common']"/>
        <xsl:variable name="summary" select="//tei:notesStmt/tei:note[@type='abstract']"/>
        <xsl:variable name="baseURL"
            >http://thedigitalwalters.org/Data/WaltersManuscripts</xsl:variable>
        <xsl:variable name="sigla">
            <xsl:value-of
                select="tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:idno"
            />
        </xsl:variable>
        <xsl:variable name="id">
            <xsl:value-of select="translate($sigla,'.','')"/>
        </xsl:variable>
        <xsl:variable name="recordURL" select="concat($baseURL,'/html/',$id)"/>
        <xsl:variable name="subjects">
            <xsl:for-each select="//tei:keywords[@scheme='#keywords']/tei:list/tei:item"
                    ><xsl:value-of select="translate(.,',','')"/>,</xsl:for-each>
        </xsl:variable>
        
        <!-- 
            This method requires searching the msItems only once in order to create a $surface-map
            variable containing ad hoc <surface-item> elements, each with @surface and @msItem 
            attributes. Thus:
            
                        <surface-msItem surface="n348.022215" msItem="n348.024452" />
                        <surface-msItem surface="n348.022220" msItem="n348.024452" />
                        ...
                        <surface-msItem surface="n348.022215" msItem="n348.024455" />
            
            This list will have each surface/msItem combination so that we can access all the 
            msItems for a single surface with a single XPath:
                            
                        $surface-map/surface-msItem[@surface = $someSurface/@xml:id]
            
            This is used later in the XSL, in place of the previous brute-force search method, 
            to print the title of each msItem that contains the surface.
            
        -->
        <xsl:variable name="surface-map" >
            <xsl:for-each select="//tei:msItem">
                <xsl:variable name="item" select="."/>
                <xsl:for-each select="tei:locus | tei:locusGrp/tei:locus">
                    <xsl:variable name="from"  select="@from"/>
                    <xsl:variable name="to"    select="@to"/>
                    <xsl:variable name="start" select="concat('fol. ', $from)" />
                    <xsl:variable name="end"   select="concat('fol. ', $to)"/>
                    <xsl:for-each select="//tei:surface[@n=$start] | //tei:surface[@n=$end] | //tei:surface[@n=$start]/following-sibling::tei:surface[@n=$end]/preceding-sibling::tei:surface[preceding-sibling::tei:surface[@n=$start]]">
                        <surface-msItem>
                            <xsl:attribute name="surface" select="@xml:id"/>
                            <xsl:attribute name="msItem" select="$item/@xml:id"/>
                        </surface-msItem>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        <!-- 
            We define $root here because, later, when we try to access the TEI document from within a for-each 
            that iterates through the <surface-item> elements we're defined above, we can't access stuff 
            like //tei:msItem; instead, we have to do this: $root//tei:msItem. 
            
            I know, right? Hacky McHackHack.
        -->
        <xsl:variable name="root" select="/"/>
        

        <xsl:result-document href="../{$id}/data/{$sigla}/sap/index.html">
            <html xmlns="http://www.w3.org/1999/xhtml">
                <head>
                    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                    <title>Facsimile of <xsl:value-of select="$title"/></title>
                    <xsl:element name="meta">
                        <xsl:attribute name="name">keywords</xsl:attribute>
                        <xsl:attribute name="content" select="$subjects"/>
                    </xsl:element>
                    <style type="text/css">
                        hr{
                            page-break-after:always;
                        }</style>
                </head>
                <body>
                    <h3>Facsimile of <xsl:value-of select="$title"/></h3>
                    <p>
                        <xsl:value-of select="$summary"/>
                    </p>
                    <hr/>
                    <p>The manuscript contained in this facsimile is the <a href="{$recordURL}"
                                ><xsl:value-of select="$title"/></a>.</p>
                    <p>To read descriptions of illustrations, figures, or initials on a page, click
                        on the folio image.</p>
                    <p>Digital images are courtesy of <a
                            href="http://www.thedigitalwalters.org/Data/WaltersManuscripts/">The
                            Digital Walters</a>, digitized collections of the Walters Art Museum,
                        Baltimore. This ebook was generated by Dot Porter.</p>
                    <hr/>
                    <p>[This page left purposefully blank.]</p>
                    <hr/>
                    <xsl:for-each select="//tei:surface">
                        <xsl:variable name="fullFolNo" select="@n"/>
                        <xsl:if
                            test="matches($fullFolNo, 'fol. \d+r$') or matches($fullFolNo, 'fol. \d+v$') or matches($fullFolNo, 'fol. \d+$')">
                            <xsl:for-each select="tei:graphic[starts-with(@url,'sap')]">
                                <xsl:variable name="file" select="substring(@url,5)"/>
                                <p>
                                    <a href="#{substring($fullFolNo,6)}"
                                        name="img-{substring($fullFolNo,6)}"
                                        title="Folio {$fullFolNo}">
                                        <img src="{$file}" alt="{$fullFolNo}"/>
                                    </a>
                                    <!--<center>Folio <xsl:value-of select="$fullFolNo"/></center>-->
                                </p>
                            </xsl:for-each>
                        </xsl:if>
                    </xsl:for-each>
                    <hr/>
                    <xsl:for-each select="//tei:surface">
                        <xsl:variable name="this_surface" select="."/>
                        <xsl:variable name="fullFolNo" select="@n"/>
                        <xsl:variable name="folNo" select="substring($fullFolNo,6)"/>
                        <xsl:variable name="rORv" select="tokenize($folNo,'\d+') [position() = 2]"/>
                        <xsl:variable name="no">
                            <xsl:if test="ends-with($folNo,'r')">
                                <xsl:value-of select="substring-before($folNo,'r')"/>
                            </xsl:if>
                            <xsl:if test="ends-with($folNo,'v')">
                                <xsl:value-of select="substring-before($folNo,'v')"/>
                            </xsl:if>
                        </xsl:variable>
                        <xsl:if
                            test="matches($fullFolNo, 'fol. \d+r$') or matches($fullFolNo, 'fol. \d+v$') or matches($fullFolNo, 'fol. \d+$')">
                            <xsl:for-each select="tei:graphic[starts-with(@url,'sap')]">
                                <xsl:variable name="imgURL"
                                    select="concat($baseURL,'/',$id,'/data/',$sigla,'/',@url)"/>

                                <p>
                                    <a href="#img-{$folNo}" name="{$folNo}">Back to image</a>
                                </p>
                                <p>
                                    <xsl:value-of select="$fullFolNo"/>
                                </p>

                                <!-- 
                                    For $this_surface, iterate through each surface-msItem with the same surface xml:id.
                                    
                                    Get the title of the associated tei:msItem. NOTE the use of $root. Does not work 
                                    otherwise. See:
                                    
                                    http://stackoverflow.com/questions/8533314/xslt-xpath-context-and-document
                                -->
                                <xsl:for-each select="$surface-map/*:surface-msItem[@surface = $this_surface/@xml:id]" >
                                    <xsl:variable name="msItem" select="@msItem"/>
                                    <p>
                                        Part of manuscript item:  <xsl:value-of select="$root//tei:msItem[@xml:id = $msItem]/tei:title"/>
                                    </p>
                                </xsl:for-each>
                                
                             <xsl:for-each select="//tei:decoNote[@n=$fullFolNo]">
                                    <p> Title: <xsl:value-of select="tei:title"/>.</p>
                                    <p>Text: <xsl:value-of
                                            select="tei:note[@type='text-identifier']"/>.</p>
                                    <p><xsl:value-of select="tei:note[@type='decoration-form']"
                                        />.</p>
                                    <p>
                                        <xsl:if test="tei:note[@type='decoration-label']">
                                            <xsl:value-of
                                                select="tei:note[@type='decoration-label']"/>
                                        </xsl:if>
                                    </p>
                                </xsl:for-each>
                                <p>
                                    <a href="{$imgURL}">View a high-resolution version of this image
                                        in a browser.</a>
                                </p>
                            </xsl:for-each>

                            <hr/>

                        </xsl:if>
                    </xsl:for-each>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    
    
</xsl:stylesheet>
