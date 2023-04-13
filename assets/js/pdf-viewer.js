import * as pdfjsLib from "../vendor/pdf"

pdfjsLib.GlobalWorkerOptions.workerSrc = '//mozilla.github.io/pdf.js/build/pdf.worker.js'
window.pdfjsLib = pdfjsLib

window.onload = async () => {
	var url = "https://arxiv.org/pdf/2001.01653.pdf";
	const loadingTask = window.pdfjsLib.getDocument(url);
	const pdf = await loadingTask.promise;

	// Load information from the first page.
	const page = await pdf.getPage(1);

	const params = {
		scale: window.devicePixelRatio
	};
	const viewport = page.getViewport(params);

	// Apply page dimensions to the `<canvas>` element.
	const canvas = document.getElementById('pdf-canvas');
	const context = canvas.getContext('2d');
	canvas.height = viewport.height;
	canvas.width = viewport.width;

	// Render the page into the `<canvas>` element.
	const renderContext = {
		canvasContext: context,
		viewport: viewport,
	};
	await page.render(renderContext);
}