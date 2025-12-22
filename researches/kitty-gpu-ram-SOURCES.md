## Research Sources - GPU & RAM Optimization

### Official Kitty Documentation
- [Kitty Performance Documentation](https://sw.kovidgoyal.net/kitty/performance/)
- [Kitty Configuration Reference](https://sw.kovidgoyal.net/kitty/conf/)
- [Ubuntu Kitty Manpage](https://manpages.ubuntu.com/manpages/jammy/man5/kitty.conf.5.html)

### GitHub Issues & Discussions
- [High memory usage #2225](https://github.com/kovidgoyal/kitty/issues/2225) - Scrollback buffer memory impact
- [High RAM use #1268](https://github.com/kovidgoyal/kitty/issues/1268) - Per-window memory overhead discussion
- [Benchmarks? #2196](https://github.com/kovidgoyal/kitty/issues/2196) - input_delay and repaint_delay tuning
- [text_composition_strategy legacy rendering issues #6209](https://github.com/kovidgoyal/kitty/issues/6209)
- [Segmentation fault with scrollback_pager #3269](https://github.com/kovidgoyal/kitty/issues/3269)

### NVIDIA & GPU Resources
- [NVIDIA OpenGL Environment Variables](https://download.nvidia.com/XFree86/Linux-x86_64/304.137/README/openglenvvariables.html)
- [NVIDIA Flipping and UBB Configuration](https://download.nvidia.com/XFree86/Linux-x86_64/304.137/README/flippingubb.html)
- [GTX 960 OpenGL Support Forums](https://www.nvidia.com/en-us/geforce/forums/geforce-graphics-cards/5/237090/gtx-960-open-gl-update/)
- [Nouveau vs Proprietary Driver Performance](https://www.phoronix.com/review/nvidia-nouveau-2019)

### Linux Memory Management
- [NixOS Swap Wiki](https://wiki.nixos.org/wiki/Swap)
- [Linux Swappiness Documentation](https://docs.kernel.org/admin-guide/sysctl/vm.html#swappiness)
- [Zram and Zswap Configuration](https://discourse.nixos.org/t/configuring-zram-and-zswap-parameters-for-optimal-performance/47852)
- [smem Memory Profiling Tool](https://opensource.com/article/21/10/memory-stats-linux-smem)
- [Understanding Memory Usage with smem](https://stevescargall.com/analyzing-linux-memory-usage-with-smem/)

### Community Discussions
- [Kitty Terminal on Reddit](https://www.reddit.com/r/commandline/comments/rehc8g/kitty_the_fast_featureful_gpu_based_terminal/)
- [Kitty GPU Acceleration Discussion](https://www.howtogeek.com/what-is-gpu-acceleration-in-linux-terminals/)
- [Plasma 6 Transparency Issues](https://bbs.archlinux.org/viewtopic.php?id=293938)
- [Space Bums Kitty Memory Analysis](https://spacebums.co.uk/kitty-terminal/)

### Technical References
- [OpenGL Swap Interval Wiki](https://www.khronos.org/opengl/wiki/Swap_Interval)
- [GLFW Documentation](https://www.glfw.org/faq#macos)
- [Typometer Latency Measurement](https://pavelfatin.com/typometer/)
