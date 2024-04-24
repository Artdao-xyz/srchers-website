<script>
	import { onMount } from "svelte";
    import "/src/style.css";
    import * as THREE from 'three';
    import { FirstPersonControls } from 'three/addons/controls/FirstPersonControls.js';
    import GUI from 'lil-gui'; 
    import CustomShaderMaterial from 'three-custom-shader-material/vanilla'
    import vertexShader from '$lib/glsl/vertex.glsl'
    import fragmentShader from '$lib/glsl/fragment.glsl'
    import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer.js'
    import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass.js'
    import { ShaderPass } from 'three/examples/jsm/postprocessing/ShaderPass.js'
    import { FXAAShader } from 'three/examples/jsm/shaders/FXAAShader.js'
    import { UnrealBloomPass } from 'three/examples/jsm/postprocessing/UnrealBloomPass.js'
    import { FilmPass } from 'three/examples/jsm/postprocessing/FilmPass.js'
    import { BokehPass } from 'three/examples/jsm/postprocessing/BokehPass.js'
	import TextScramble from '$lib/TextScramble.js';
    import { RGBELoader } from 'three/examples/jsm/loaders/RGBELoader.js';

    let canvas, h1, h2, controls, active, srcFile;
    let wrapper;
    let loaded = false;
    
    onMount(async() => {

        active = window.location.hash === '#debug';

        const sizes = {
            width: canvas.parentElement.clientWidth,
            height: canvas.parentElement.clientHeight,
            pixelRatio: Math.min(window.devicePixelRatio, 2)
        };

        const scene = new THREE.Scene();

        const renderer = new THREE.WebGLRenderer({
            canvas,
            alpha: true,
            antialias: true,
            powerPreference: 'high-performance',
        })
        renderer.outputEncoding = THREE.sRGBEncoding;
        renderer.shadowMap.enabled = true
        renderer.shadowMap.type = THREE.PCFSoftShadowMap
        renderer.toneMapping = THREE.ACESFilmicToneMapping
        renderer.toneMappingExposure = 1.3
        renderer.setSize(sizes.width, sizes.height)
        renderer.setPixelRatio(sizes.pixelRatio);
        scene.background = new THREE.Color('#F1E7D8')

        const resolutionPlane = { 'Resolution' : 500 }

        const geometry = new THREE.PlaneGeometry(3, 3, resolutionPlane.Resolution, resolutionPlane.Resolution)
        geometry.deleteAttribute('uv')
        geometry.deleteAttribute('normal')
        geometry.rotateX(- Math.PI * 0.5)
        // geometry.translate(0.0, 0.0, 0.0 )

        /**
         * Environment map
         */
        // const rgbeLoader = new RGBELoader()
        // rgbeLoader.load('/spruit_sunrise.hdr', (environmentMap) =>
        // {
        //     environmentMap.mapping = THREE.EquirectangularReflectionMapping

        //     // scene.background = environmentMap
        //     scene.backgroundBlurriness = 0.5
        //     // scene.environment = environmentMap
        // })

        
        const uniforms = {
            uTime: new THREE.Uniform(0),
            uPositionFrequency: new THREE.Uniform(0.55),
            uStrength: new THREE.Uniform(0.65),
            uWarpFrequency: new THREE.Uniform(0.2),
            uWarpStrength: new THREE.Uniform(0.9),
        }

        const material = new CustomShaderMaterial({
            // CSM
            baseMaterial: THREE.MeshStandardMaterial,
            vertexShader: vertexShader,
            fragmentShader: fragmentShader,
            uniforms: uniforms,
            silent: true,

            // MeshPhysicalMaterial
            metalness: 0.75,
            roughness: 0.75,
            color: '#ffffff',
        })

        const terrain = new THREE.Mesh(geometry, material)
        scene.add(terrain)
        let lightColor = '#ffffff';
        let directionalLight = new THREE.DirectionalLight(lightColor, 2.0)
        directionalLight.position.set(-6.25, 8, -4)
        directionalLight.castShadow = true
        directionalLight.shadow.mapSize.set(1024, 1024)
        directionalLight.shadow.camera.near = 0.1
        directionalLight.shadow.camera.far = 30
        directionalLight.shadow.camera.top = 8
        directionalLight.shadow.camera.right = 8
        directionalLight.shadow.camera.bottom = -8
        directionalLight.shadow.camera.left = -8
        scene.add(directionalLight)
        
        const ambientLight = new THREE.AmbientLight('#f0f5ff', .5)
        scene.add(ambientLight)

        const camera = new THREE.PerspectiveCamera(30, sizes.width / sizes.height, 0.1, 100)
        camera.position.set(0, 0.4, 0);
        camera.rotation.x = -Math.PI / 5;
        //debug view
        // camera.position.set(0, 10.20, 0);
        // camera.rotation.x = -Math.PI / 2;

        scene.add(camera)

        //FirstPersonControls
        controls = new FirstPersonControls(camera, wrapper);
        controls.lookVertical = false;
        controls.movementSpeed = 0.0;
        controls.lookSpeed = .002;        

        const fog = new THREE.Fog('#F1E7D8', 0.001, 1.50);
        scene.fog = fog;

        const composer = new EffectComposer(renderer);
        composer.setSize(sizes.width, sizes.height);
        composer.setPixelRatio(sizes.pixelRatio);
        composer.addPass(new RenderPass(scene, camera));

        const effectFXAA = new ShaderPass(FXAAShader);
        effectFXAA.uniforms['resolution'].value.set(1 / ( sizes.width * sizes.pixelRatio ), 1 / ( sizes.height * sizes.pixelRatio ));
        composer.addPass(effectFXAA);

        const bokehPass = new BokehPass(scene, camera, {
            focus: 0.35,
            aperture: 0.005,
            maxblur: 0.005,
            width: sizes.width,
            height: sizes.height
        });
        composer.addPass(bokehPass);

        const bloomPass = new UnrealBloomPass(new THREE.Vector2(sizes.width, sizes.height), 1.5, 0.4, 1.25);
        bloomPass.enabled = false;
        composer.addPass(bloomPass);

        const filmPass = new FilmPass(0.15, 0.025, 648, false);
        composer.addPass(filmPass);

        onresize = () => {

            // if (window.innerWidth !== sizes.width) {

                sizes.width = canvas.parentElement.clientWidth;
                sizes.height = canvas.parentElement.clientHeight;

                camera.aspect = sizes.width / sizes.height;
                camera.updateProjectionMatrix();

                controls.handleResize();
                renderer.setSize(sizes.width, sizes.height);
                renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

            // };
            
        };

        const clock = new THREE.Clock()
        let uTimeAmount = 0.20;

        loaded = true;
        setTimeout(() => scramble(), 0);

        const tick = () => {
            const elapsedTime = clock.getElapsedTime()

            uniforms.uTime.value = elapsedTime * uTimeAmount;

            if (controls) {controls.update(.05)};
            composer.render()
            window.requestAnimationFrame(tick)
        }
        tick()

        if (active) {
            let gui = new GUI();

            const folderShader = gui.addFolder('Shader')        
            // gui.add( resolutionPlane, 'Resolution', [ 50, 100, 200, 500 ] ).onChange((value) => {
            //     console.log(value)
            //     // const geometry = new THREE.PlaneGeometry(3, 3, value, value)
            //     geometry.dispose(); // Clean up previous geometry
            //     // terrain.geometry = geometry;
            //     }
            // )

            folderShader.add(uniforms.uPositionFrequency, 'value', 0.5, 0.85, 0.001).name('uPositionFrequency')
            folderShader.add(uniforms.uStrength, 'value', 0.35, 0.95, 0.001).name('uStrength')
            folderShader.add(uniforms.uWarpFrequency, 'value', 0, 0.5, 0.001).name('uWarpFrequency')
            folderShader.add(uniforms.uWarpStrength, 'value', 0, 4, 0.001).name('uWarpStrength')
            folderShader.add({ uTimeAmount: uTimeAmount }, 'uTimeAmount', 0, 5, 0.001).name('uVelocity').onChange((value) => {
                uTimeAmount = value
            })
            const lightFolder = gui.addFolder('Light')
            lightFolder.addColor({ lightColor: '#ffffff' }, 'lightColor').name('color').onChange((value) => {
                directionalLight.color.set(value)
            })
            lightFolder.add(directionalLight, 'intensity', 0, 7, 0.001).name('intensity');
            const cameraFolder = gui.addFolder('Camera')
            cameraFolder.add(camera.position, 'y', 0, 10, 0.001).name('Y')

            const postProcessFolder = gui.addFolder('Post Process')
            postProcessFolder.add(filmPass, 'enabled').name('Film Pass')
            postProcessFolder.add(effectFXAA, 'enabled').name('FXAA')
            postProcessFolder.add(bloomPass, 'enabled').name('Bloom')
            postProcessFolder.add(bloomPass, 'threshold', 0, 1, 0.001).name('Bloom Threshold')
            postProcessFolder.add(bokehPass, 'enabled').name('Bokeh')
            postProcessFolder.add(fog, 'far', 0.001, 15, 0.001).name('Fog Far')
        }
    });

    const scramble = async () => {

        const title = new TextScramble(h1, h1.textContent, 15);
        await title.start();

        const subtitle = new TextScramble(h2, h2.textContent, 15);
        await subtitle.start();

    }
</script>


<div class="fixed top-0 left-0 -z-10 h-screen w-full">
    <canvas bind:this={canvas}></canvas>
</div>
<div bind:this={wrapper} class="h-lvh font-jetbrains-mono text-black">

    {#if loaded}
        <div class="h-lvh flex flex-col justify-center items-center md:gap-10">
            <h1 on:mouseenter={scramble} bind:this={h1} class="text-center text-4xl md:text-6xl font-bold leading-10 tracking-[0.25em]">SRCHERS</h1>
            <img class="" src="/srchers-logo.png" alt="Logo">

            <div class="flex flex-col items-center gap-10">
                <h2 bind:this={h2} class="text-center text-xl md:text-3xl font-semibold leading-10 tracking-widest">LAUNCH <br class="md:hidden">2025</h2>
                <img src="/arrow.png" alt="scroll">
            </div>
        </div>

        <div class="h-lvh flex flex-col justify-center items-center md:w-1/2 2xl:w-1/3 mx-auto text-center gap-10 md:gap-20">
            <p class="text-center text-lg md:text-xl font-extrabold uppercase leading-relaxed tracking-wide">Beyond different</p>
            <p class="text-base md:text-xl font-normal px-7 py-4 md:px-0 md:leading-7 tracking-tight md:tracking-wide">
                At SRCHERS, we aim to be the bridge into a new world of futuristic fashion, design, and sustainability. We believe in pushing the boundaries while redefining what luxury and class looks like for the modern era.
                Our brand prioritizes innovation, elegance, and sustainability, fusing style with conscience. We redefine luxury bags and luggage with new creations through our distinctive angular minimal designs. Each piece is meticulously crafted with clean lines, geometric shapes, and a minimalist aesthetic that exudes modernity and sophistication. Our designs not only elevate style and taste, but also reflect a conscious effort to minimize excess, embrace simplicity, and inspire the allure of distant horizons and the magic of discovery.
            </p>
        </div>
        {/if}
</div>