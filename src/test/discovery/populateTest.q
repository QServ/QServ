//*****************************************************************
//
// Dummy data to populate the discovery service.
// Used when developing the web interface to see that it looks ok.
//
//*****************************************************************
`Services upsert (`TEST_SVC;`DC1;`192.168.0.197;1111;`w;1;.z.P);
`Services upsert (`TEST_SVC2;`DC1;`192.168.0.197;1111;`w;1;.z.P);
`Services upsert (`TEST_SVC;`DC2;`studio;1111;`w;1;.z.P);
`Services upsert (`TEST_SVC2;`DC2;`studio;1111;`w;1;.z.P);

`Tables upsert (`TEST_TBL;1;`DC1;`192.168.0.197;1111;1;.z.P);
`Tables upsert (`TEST_TBL;1;`DC2;`192.168.1.197;1112;1;.z.P);
`Tables upsert (`TEST_TBL;2;`DC1;`192.168.0.198;1111;1;.z.P);
`Tables upsert (`TEST_TBL;2;`DC2;`192.168.1.198;1112;1;.z.P);
`Tables upsert (`TEST_TBL2;1;`DC1;`192.168.0.199;1117;1;.z.P);
`Tables upsert (`TEST_TBL2;1;`DC2;`192.168.2.199;1118;1;.z.P);

`Functions upsert (`TEST_FUN;`DC1;`192.168.0.197;2222;1;.z.P);
`Functions upsert (`TEST_FUN;`DC2;`192.168.2.197;2224;1;.z.P);
`Functions upsert (`TEST_FUN2;`DC1;`192.168.0.198;2222;1;.z.P);
`Functions upsert (`TEST_FUN2;`DC2;`192.168.2.199;2225;1;.z.P);
`Functions upsert (`TEST_FUN3;`DC1;`192.168.0.190;2228;1;.z.P);
