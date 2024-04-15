<script>
	import { onMount } from "svelte";
    import "/src/style.css";
    import * as THREE from 'three';
    import { FirstPersonControls } from 'three/addons/controls/FirstPersonControls.js';
    import GUI from 'lil-gui'; 
    import { OrbitControls } from 'three/addons/controls/OrbitControls.js'
    import CustomShaderMaterial from 'three-custom-shader-material/vanilla'
    import vertexShader from '$lib/glsl/vertex.glsl'
    import fragmentShader from '$lib/glsl/fragment.glsl'
    import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer.js'
    import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass.js'
    import { ShaderPass } from 'three/examples/jsm/postprocessing/ShaderPass.js'
    import { FXAAShader } from 'three/examples/jsm/shaders/FXAAShader.js'
    import { UnrealBloomPass } from 'three/examples/jsm/postprocessing/UnrealBloomPass.js'
    import { FilmPass } from 'three/examples/jsm/postprocessing/FilmPass.js'
    import { GlitchPass } from 'three/examples/jsm/postprocessing/GlitchPass.js'

    let canvas;
    let controls;
    let debug, active;
    let map, bmap, dmap;

    onMount(() => {

        active = window.location.hash === '#debug';

        const sizes = {
            width: window.innerWidth,
            height: window.innerHeight
        };

        const scene = new THREE.Scene();

        const renderer = new THREE.WebGLRenderer({
            canvas: canvas,
            antialias: true,
        })
        renderer.shadowMap.enabled = true
        renderer.shadowMap.type = THREE.PCFSoftShadowMap
        renderer.toneMapping = THREE.ACESFilmicToneMapping
        renderer.toneMappingExposure = 1
        renderer.setSize(sizes.width, sizes.height)
        renderer.setPixelRatio(sizes.pixelRatio);
        // scene.background = new THREE.Color('#ff')

        const geometry = new THREE.PlaneGeometry(25, 25, 1000, 1000)
        geometry.deleteAttribute('uv')
        geometry.deleteAttribute('normal')
        geometry.rotateX(- Math.PI * 0.5)
        geometry.translate(0.0, 0.0, -12 )

        
        const uniforms = {
            uTime: new THREE.Uniform(0),
            uPositionFrequency: new THREE.Uniform(0.1),
            uStrength: new THREE.Uniform(1.0),
            uWarpFrequency: new THREE.Uniform(4.),
            uWarpStrength: new THREE.Uniform(1.75),
        }

        const material = new CustomShaderMaterial({
            // CSM
            baseMaterial: THREE.MeshStandardMaterial,
            vertexShader: vertexShader,
            fragmentShader: fragmentShader,
            uniforms: uniforms,
            silent: true,

            // MeshPhysicalMaterial
            metalness: 0,
            roughness: 0.5,
            color: '#ffffff',
        })

        const depthMaterial = new CustomShaderMaterial({
            // CSM
            baseMaterial: THREE.MeshDepthMaterial,
            vertexShader: vertexShader,
            uniforms: uniforms,
            silent: true,

            // MeshDepthMaterial
            depthPacking: THREE.RGBADepthPacking
        })

        const terrain = new THREE.Mesh(geometry, material)
        terrain.customDepthMaterial = depthMaterial
        scene.add(terrain)

        let directionalLight = new THREE.DirectionalLight('#ffffff', 3.5)
        directionalLight.position.set(6.25, 3, 4)
        directionalLight.castShadow = true
        directionalLight.shadow.mapSize.set(1024, 1024)
        directionalLight.shadow.camera.near = 0.1
        directionalLight.shadow.camera.far = 30
        directionalLight.shadow.camera.top = 8
        directionalLight.shadow.camera.right = 8
        directionalLight.shadow.camera.bottom = -8
        directionalLight.shadow.camera.left = -8
        scene.add(directionalLight)
        
        const ambientLight = new THREE.AmbientLight('#ffffff', .5)
        scene.add(ambientLight)

        const camera = new THREE.PerspectiveCamera(35, sizes.width / sizes.height, 0.1, 100)
        camera.position.set(0, 1.5, 0);
        camera.rotation.x = -Math.PI / 8;
        scene.add(camera)

        //OrbitControls
        // const controls = new OrbitControls(camera, canvas)
        // controls.enableDamping = true

        //FirstPersonControls
        controls = new FirstPersonControls(camera, renderer.domElement);
        controls.lookVertical = false;
        controls.movementSpeed = 0.00000000001;
        controls.lookSpeed = .0025;        

        const fog = new THREE.Fog('#000000', 1, 20);
        scene.fog = fog;

        const composer = new EffectComposer(renderer);
        composer.addPass(new RenderPass(scene, camera));

        const effectFXAA = new ShaderPass(FXAAShader);
        effectFXAA.uniforms['resolution'].value.set(1 / sizes.width, 1 / sizes.height);
        composer.addPass(effectFXAA);

        const bloomPass = new UnrealBloomPass(new THREE.Vector2(sizes.width, sizes.height), 1.5, 0.4, 0.95);
        bloomPass.enabled = false;
        composer.addPass(bloomPass);

        const filmPass = new FilmPass(0.35, 0.025, 648, false);
        composer.addPass(filmPass);

        const glitchPass = new GlitchPass();
        glitchPass.enabled = false;
        composer.addPass(glitchPass);

        onresize = () => {
            sizes.width = window.innerWidth;
            sizes.height = window.innerHeight;

            camera.aspect = sizes.width / sizes.height;
            camera.updateProjectionMatrix();

            controls.handleResize();
            renderer.setSize(sizes.width, sizes.height);
        };

        const clock = new THREE.Clock()
        let uTimeAmount = 0.50;

        const tick = () => {
            const elapsedTime = clock.getElapsedTime()

            uniforms.uTime.value = elapsedTime * uTimeAmount;

            if (controls) {controls.update(.05)};
            // renderer.render(scene, camera)
            composer.render()
            window.requestAnimationFrame(tick)
        }
        tick()

        
        if (active) {
            let gui = new GUI();

            const folderShader = gui.addFolder('Shader')
            folderShader.add(uniforms.uPositionFrequency, 'value', 0.06, 0.15, 0.001).name('uPositionFrequency')
            folderShader.add(uniforms.uStrength, 'value', 0.1, 3, 0.001).name('uStrength')
            folderShader.add(uniforms.uWarpFrequency, 'value', 0, 8, 0.001).name('uWarpFrequency')
            folderShader.add(uniforms.uWarpStrength, 'value', 0, 5, 0.001).name('uWarpStrength')
            // add a parameter to increase uTimeAmount
            folderShader.add({ uTimeAmount: uTimeAmount }, 'uTimeAmount', 0, 5, 0.001).name('uVelocity').onChange((value) => {
                uTimeAmount = value
            })
            const lightFolder = gui.addFolder('Light')
            lightFolder.add(directionalLight, 'intensity', 0, 5, 0.001).name('intensity');
            const cameraFolder = gui.addFolder('Camera')
            cameraFolder.add(camera.position, 'y', 0, 10, 0.001).name('Y')

            const postProcessFolder = gui.addFolder('Post Process')
            postProcessFolder.add(filmPass, 'enabled').name('Film Pass')
            postProcessFolder.add(effectFXAA, 'enabled').name('FXAA')
            postProcessFolder.add(bloomPass, 'enabled').name('Bloom')
            postProcessFolder.add(bloomPass, 'threshold', 0, 1, 0.001).name('Bloom Threshold')
            postProcessFolder.add(glitchPass, 'enabled').name('Glitch')
        }
    });
</script>

<canvas bind:this={canvas}></canvas>

<h1 class="text-blue-400 absolute left-1/2 -translate-x-1/2 top-1/2 -translate-y-1/2 text-6xl select-none">SRCHRS</h1>
