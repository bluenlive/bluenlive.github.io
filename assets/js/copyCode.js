/* ==========================================================================
   Code Highlighter copy function
   ========================================================================== */

const codeBlocks = document.querySelectorAll(
  ".code-header + .highlighter-rouge"
);
const copyCodeButtons = document.querySelectorAll(".copy-code-button");

copyCodeButtons.forEach((copyCodeButton, index) => {
  const code = codeBlocks[index].innerText;
  let id;

  copyCodeButton.addEventListener("click", () => {
    window.navigator.clipboard.writeText(code);

    const img = copyCodeButton.querySelector("img");
    img.src = "/assets/images/check.png";

    if (id) {
      clearTimeout(id);
    }

    id = setTimeout(() => {
      img.src = "/assets/images/copy.png";
    }, 2000);
  });
});
