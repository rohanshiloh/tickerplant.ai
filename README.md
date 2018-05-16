# tickerplant.ai
## streamline setup of a tickerplant to capture real-time level 2 trade order books on w32 for the q/kdb+/qPy/python stack

> console config with icons

> choice of dos/powershell/bash shells

> setup of micro editor

> setup of python and qPy

> RESTful interfaces to the bats and iex exchanges

pre-install : make sure 'developer mode' is set on windows
pre-install : download and install free w32 version of q/kdb+ following these instructions https://code.kx.com/wiki/Tutorials/Installation#Microsoft_Windows

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



what the powershell install file does:

1. downloads and extracts console2
   - config file provided and copied to console2 folder
2. downloads and labels all relevant reference material

- [x] pca for tick analysis
- [ ] portfolio rebalancing; multi period and multi strategy
- [ ] transaction cost analysis
- [ ] actual structural covariance like please don't lie if its not properly regularized cause that makes it not properly structural and you're a fucking liar, sir
- [ ] get a job in belfast (link to that video)
- [ ] (long term) the perfect distributed svm implementation for q/kdb+