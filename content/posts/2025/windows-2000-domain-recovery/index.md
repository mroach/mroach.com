---
title: "Windows 2000 Domain Recovery"
date: 2025-04-14T21:17:38+02:00
---

I have a Windows 2000 Active Directory domain that had one domain controller.
I added a second domain controller and performed what I thought were all necessary
steps to prepare the new domain controller to be the only one in the domain:

1. In **Active Directory Sites and Services**, I enabled **Global Catalog** by
right-clicking on **NTDS Settings** for the new controller.
2. In **Active Directory Users and Computers**, I right-clicked on the domain,
clicked **Operations Masters...** and set my new controller to the **RID**, **PDC**,
and **Infrastructure** master.

As far as I understand, this should have done the trick. After running `dcpromo`
on the old controller to demote it, things started going wrong. I could no longer
join the domain on new computers. I would get errors about not being able
to allocate a resource identifier. Uh oh.

## Debugging

You'll want to have the **Windows 2000 Support Tools** installed.
The installer is on the Windows 2000 CD in `Support\Tools\setup.exe`.

I ran `dcdiag` to see what was going on.
Things went wrong with the `KnowsOfRoleHodlers` tests. I would get:

```
Warning: CN="NTDS Settings DEL:... is the PDC Owner, but is deleted.
Warning: CN="NTDS Settings DEL:... is the Rid Owner, but is deleted.
Warning: CN="NTDS Settings DEL:... is the Infrastructure Update Owner, but is deleted.
```

Then, the `RidManager` test would fail too:

```
Warning: FSMO Role Owner is deleted.
Warning: rid set reference is deleted.
ldap_search_sW of CN=RID Set DEL:... for rid info failed with 2: Win32 Error 2
```

Things were looking grim and a lot of the search results I found didn't really help.
One of them spoke of using `ntdsutil` to do metadata cleanup, but this didn't work for me.

## The Fix

I finally found that `ntdsutil` *was* the tool for the job, but nobody had documented
how to fix my specific problem. So, here's how I fixed it.

`ntdsutil` has an interface where you enter menus and sub menus. Some menus have
you set state and then go back and use those settings.

You can type `?` and hit Enter to get help and lists of commands.

In my case the domain controller is `RLDC2`.

1. Open `cmd.exe` and run `ntdsutil`
2. Type `roles`, hit Enter.
3. Type `connections`, hit Enter.
4. Type `connect to server RLDC2`, hit Enter.

Now you're connected to the domain controller that you want to seize the missing
operations master roles.

You should be at a prompt that says `fsmo maintenance:`.
Now we'll seize roles one by one, answering **Yes** to all prompts.

1. Type `seize infrastructure master`, hit Enter.
2. Type `seize pdc`, hit Enter.
3. Type `seize rid master`, hit Enter.

Now if you run `dcdiag` you should get a passing result! At least I did.

The session should look something like:

```
C:\> ntdsutil
ntdsutil: roles
fsmo maintenance: connections
server connections: connect to server rldc2
server connections: quit
fsmo maintenance: seize infrastructure master
fsmo maintenance: seize rid master
fsmo maintenance: seize pdc
fsmo maintenance: quit
ntdsutil: quit
```

{{< figure
    src="images/role-seize.png"
    alt="Screenshot of role seizure using ntdsutil"
>}}
