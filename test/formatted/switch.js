switch (a) {
  case 1:
    console.log(1);
    break;

  default:
    console.log("else");
    break;
}

(function () {
  switch (a) {
    case 1:
      return "one";

    case 2:
      return "got " + "two";

    default:
      return "somthing else";
  }
})();