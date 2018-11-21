self: super:

let
  patch824 = super.fetchpatch {
    url    = "https://github.com/NixOS/nixops/pull/824.patch";
    sha256 = "0xpjx94mf1zy3f0dwpnlmszmaig17qp932kc32k1k9jhm1dxx2z1";
  };

in {
  nixops = super.nixops.overrideAttrs(attrs: {
    patches = (attrs.patches or []) ++ [ patch824 ];
  });
}
