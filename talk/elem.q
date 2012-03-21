
\d .elem_impl
sim_impl:{[x;y] yy: (e:.ql.randn x) + (b:neg 0.5-y?1.0) mmu flip xx:.ql.randn (x;y);
           `yy`xx`b`e!(yy;xx;b;e)}
sim_beta:{[x;y] yy: (e:.ql.randn x) + y mmu flip xx:.ql.randn (x;count y);
           `yy`xx`b`e!(yy;xx;y;e)}
add_intercept:{ [x;y] `yy`xx`b`e!(y+x`yy; flip (1f,flip x`xx);y,x`b;x`e ) }
sim:()!()
sim[`$"-6"]:{:sim_impl[x;1] }
sim[`6]:{:sim_impl[x 0;x 1] }
sim[`0]:{:sim_beta[x 0;x 1] }

\d .

\d .elem

sim:{[x] sim:.elem_impl.sim[`$ string type x] x;
    :$[3<=count x;.elem_impl.add_intercept[sim;x[2]]; sim]}

linregtests:{[R]
    tstat:R[`b]%se:sqrt R[`S]@'til count R`S;
    fstat:(R[`df]*rss-tss:{x mmu x}R[`y]-+/[R`y]%R`n)%(1-R`m)*rss:e mmu e:R`e;
    R,`se`tstat`tpval`rss`tss`r2`r2adj`fstat`fpval!(se;tstat;
        2*1-R[`df] .qml.stcdf/:abs tstat;rss;tss;1-rss%tss;
        1-(rss*-1+R`n)%tss*R`df;fstat;1-.qml.fcdf[-1+R`m;R`df;fstat])};

linreg:{[y;X]
    if[any[null y:"f"$y]|any{any null x}'[X:"f"$X];'`nulls];
    if[$[0=m:count X;1;m>n:count X:flip X];'`length];
    e:y-X mmu b:(Z:inv[flip[X]mmu X])mmu flip[X]mmu y;
    linregtests ``X`y`S`b`e`n`m`df!(::;X;y;Z*mmu[e;e]%n-m;b;e;n;m;n-m)};
\d .