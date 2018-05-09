# tickerplant.ai
## streamline setup of tickerplant on w32 for independent ml/bc researchers on the q/kdb+/qPy/python stack
> console config with icons
> choice of dos/powershell/bash shells
> setup of micro editor
> RESTful interfaces to the bats and iex exchanges

```
startup summary
1.  tp   : q tick.q sym . -p 5000
2.  rdb  : q tick/r.q :5000 -p 5001
3.  hdb  : q tick/h.q sym -p 5012
4.  fh   : q .\feedhandler.q
5.  ctp  : q chainedtick.q :5000 -p 5110 -t 1000
6.  crdb :
9.  gw   :
10. wdb  :
```

pre-install : make sure 'developer mode' is set on windows

what the powershell install file does:

1. downloads and extracts console2
   - config file provided and copied to console2 folder
2. downloads and labels all relevant reference material

- [x] pca for tick analysis
- [ ] portfolio rebalancing
- [ ] get a job in belfast