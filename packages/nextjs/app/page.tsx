"use client";

import Link from "next/link";
import type { NextPage } from "next";
import { useAccount } from "wagmi";
import { BugAntIcon, MagnifyingGlassIcon } from "@heroicons/react/24/outline";
import { Address } from "~~/components/scaffold-eth";
import HouseCard from '../components/casa';
import CasaCarrusel from '../components/casa_vers2';


const Home: NextPage = () => {
  const { address: connectedAddress } = useAccount();

  const images = [
    { src: 'casa1.jpg' },
    { src: 'casa2.jpg' },
    { src: 'casa3.jpg' },
    { src: 'casa4.jpg' },
  ];

  return (
    <>
      <div className="flex items-center flex-col flex-grow pt-10">
        <div className="px-5">
          
          <h1 className="text-center text-6xl font-bold">
          <img src="casa.png" alt="Casa" width="100px" />
            CasaSegura
          </h1>
          
          <div className="flex justify-center items-center space-x-2 flex-col sm:flex-row">
            
          </div>
          <p className="text-center text-lg">
            Somos una St🚀rTup especializada{" "}
            <code className="italic bg-base-300 text-base font-bold max-w-full break-words break-all inline-block">
                en tu seguridad
            </code>
          </p>
          <p className="text-center text-lg">
            Para transacciones inmobiliarias de confianza{" "}
            <code className="italic bg-base-300 text-base font-bold max-w-full break-words break-all inline-block">
              La Tecnología de Ethereum 
            </code>{" "}
            en tus manos.{" "}
            
          </p>
        </div>

        <div className="flex-grow bg-base-300 w-full mt-16 px-8 py-12">
          <div className="flex justify-center items-center gap-12 flex-col sm:flex-row">
            

            <HouseCard 
              imageSrc="casa1.jpg" 
              title="Casa en Santa Cruz" 
              description="Entre 7mo y 8vo anillo Este, Santa Cruz de la Sierra" 
            />
            <HouseCard 
              imageSrc="casa2.jpg" 
              title="Casa en La Paz" 
              description="Zona Sur, Calacoto, La Paz" 
            />
            <HouseCard 
              imageSrc="casa3.jpg" 
              title="Casa en Cochabamba" 
              description="Tiquipaya, Cochabamba" 
            />

            <br />

            <CasaCarrusel images={images} />

            <br />
            



            <br />



          </div>
        </div>
      </div>
    </>
  );
};

export default Home;
