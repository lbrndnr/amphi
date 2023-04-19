import * as pdfjsLib from '../vendor/pdf'
import * as pdfjsWorker from '../vendor/pdf.worker' // bundles pdf.worker correctly

pdfjsLib.GlobalWorkerOptions.workerSrc = '../vendor/pdf.worker.js'

window.onload = async () => {
	var url = "https://arxiv.org/pdf/2001.01653.pdf";
	const loadingTask = pdfjsLib.getDocument(url);
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

	// // Wait for rendering to finish
    // renderTask.promise.then(function() {
	// 	// Returns a promise, on resolving it will return text contents of the page
	// 	return page.getTextContent();
	//   }).then(function(textContent) {
  
	// 	// Assign CSS to the textLayer element
	// 	var textLayer = document.getElementById("text-layer");
  
	// 	textLayer.scale = window.devicePixelRatio;
	// 	textLayer.height = viewport.height;
	// 	textLayer.width = viewport.width;

	// 	textLayer.style.left = canvas.offsetLeft + 'px';
	// 	textLayer.style.top = canvas.offsetTop + 'px';
	// 	textLayer.style.height = canvas.offsetHeight + 'px';
	// 	textLayer.style.width = canvas.offsetWidth + 'px';
  
	// 	// Pass the data to the method for rendering of text over the pdf canvas.
	// 	pdfjsLib.renderTextLayer({
	// 	  textContentSource: textContent,
	// 	  container: textLayer,
	// 	  viewport: viewport,
	// 	  textDivs: []
	// 	});
	// });
}