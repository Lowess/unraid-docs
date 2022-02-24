---
title: 'Introduction to docker'
date: 2022-02-23T13:14:39+10:00
weight: 1
---

Taken from [Unraid Forum > Docker Template Xml Schema](https://forums.unraid.net/topic/38619-docker-template-xml-schema/)
```xml
<?xml version="1.0" encoding="utf-8"?>
<Container>
  <Name>Pints</Name>
  <Description>Raspberry Pints, beer tap display app[br]IMPORTANT :- YOU MUST CHANGE THE HOST PORT BELOW</Description>
  <Registry>https://registry.hub.docker.com/u/sparklyballs/pints/</Registry>
  <Repository>sparklyballs/pints</Repository>
  <BindTime>true</BindTime>
  <Privileged>false</Privileged>
  <Environment/>
  <Networking>
    <Mode>bridge</Mode>
    <Publish>
      <Port>
        <HostPort>81</HostPort>
        <ContainerPort>80</ContainerPort>
        <Protocol>tcp</Protocol>
      </Port>
    </Publish>
  </Networking>
  <Data>
    <Volume>
      <HostDir>/mnt/cache/appdata/pints/www</HostDir>
      <ContainerDir>/var/www/Pints</ContainerDir>
      <Mode>rw</Mode>
    </Volume>
    <Volume>
      <HostDir>/mnt/cache/appdata/pints/config</HostDir>
      <ContainerDir>/config</ContainerDir>
      <Mode>rw</Mode>
    </Volume>
  </Data>
  <Version>05616fd2</Version>
  <WebUI>http://[iP]:[PORT:80]/</WebUI>
  <Banner>http://whatsmybeeragain.com/wp-content/uploads/2013/12/Whats-My-Beer-Logo-Banner-2-01-e1318366883801.png</Banner>
  <Icon>http://fullersbarbeerfest.co.uk/files/6113/8705/6693/light-beer.png</Icon>
  <ExtraParams></ExtraParams>
</Container>
```